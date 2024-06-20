#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <signal.h>
#include <string.h>
#include <stdbool.h>

#define SERVER_FIFO '/tmp/my_fifo'
#define CLIENT_FIFO_TEMPLATE '/tmp/client.%d.fifo'
#define BUFFER_SIZE 256
#define MAX_CLIENTS 10

// Структура для хранения информации о клиенте
typedef struct
{
  pid_t pid;
  int fifoFd;
  char fifoName[BUFFER_SIZE];
  int expressionCount;
} ClientInfo;

ClientInfo clients[MAX_CLIENTS];
int numClients = 0;
int currentClient = 0;
bool running = true;

void handleSigusr1(int sig);
void handleSigint(int sig);
void handleSigusr2(int sig);

void addClient(pid_t pid);
void removeClient(pid_t pid);
void sendDataToClients(const char *data);
void sendSignalToClients(int signal);
void collectStatistics();
void finalStatistics();
void handleClientStatistic(const char *buffer);

int main(int argc, char *argv[])
{
  FILE *file = NULL;
  int serverFifoFD;
  char buffer[BUFFER_SIZE];

  // Установка обработчиков сигналов
  signal(SIGUSR1, handleSigusr1);
  signal(SIGINT, handleSigint);
  signal(SIGUSR2, handleSigusr2);

  // Создание FIFO
  if (mkfifo(SERVER_FIFO, 0666) == -1)
  {
    if (errno != EEXIST)
    {
      perror('FIFO creation error');
      return 1;
    }
  }

  // Открытие FIFO для чтения в неблокирующем режиме
  serverFifoFD = open(SERVER_FIFO, O_RDONLY | O_NONBLOCK);
  if (serverFifoFD == -1)
  {
    perror('FIFO open error');
    return 1;
  }

  // Если указан файл, открываем его
  if (argc > 1)
  {
    file = fopen(argv[1], 'r');
    if (file == NULL)
    {
      perror('File open error');
      close(serverFifoFD);
      unlink(SERVER_FIFO);
      return 1;
    }
  }
  else
  {
    // Использование stdin, если путь не указан
    file = stdin;
  }

  // Основной цикл обработки
  while (running)
  {
    ssize_t bytesRead = read(serverFifoFD, buffer, sizeof(buffer) - 1);
    if (bytesRead > 0)
    {
      buffer[bytesRead] = '\0';
      pid_t pid = atoi(buffer);
      addClient(pid);
    }

    if (file && fgets(buffer, sizeof(buffer), file) != NULL)
    {
      sendDataToClients(buffer);
    }
    else if (!file)
    {
      usleep(100000); // Задержка, чтобы не нагружать CPU
    }
  }

  // Закрытие и удаление FIFO
  close(serverFifoFD);
  unlink(SERVER_FIFO);

  // Финальная статистика
  final_statistics();

  return 0;
}

void addClient(pid_t pid)
{
  if (numClients >= MAX_CLIENTS)
  {
    fprintf(stderr, 'Max amount of clients has been reached\n');
    return;
  }

  ClientInfo *client = &clients[numClients];
  client->pid = pid;
  client->expressionCount = 0;
  snprintf(client->fifoName, sizeof(client->fifoName), CLIENT_FIFO_TEMPLATE, pid);

  // Открытие FIFO для записи
  client->fifoFd = open(client->fifoName, O_WRONLY);
  if (client->fifoFd == -1)
  {
    perror('Error of open client FIFO');
    return;
  }

  numClients++;
}

void sendDataToClients(const char *data)
{
  if (numClients == 0)
    return;

  ClientInfo *client = &clients[currentClient];
  ssize_t bytesWritten = write(client->fifoFd, data, strlen(data) + 1);
  if (bytesWritten == -1)
  {
    perror('Error of write to client FIFO');
    remove_client(client->pid);
  }

  currentClient = (currentClient + 1) % numClients;
}

void removeClient(pid_t pid)
{
  for (int i = 0; i < numClients; i++)
  {
    if (clients[i].pid == pid)
    {
      close(clients[i].fifoFd);
      unlink(clients[i].fifoName);
      clients[i] = clients[numClients - 1];
      numClients--;
      break;
    }
  }
}

void sendSignalToClients(int signal)
{
  for (int i = 0; i < numClients; i++)
  {
    kill(clients[i].pid, signal);
  }
}

void handleSigusr1(int sig)
{
  printf('SIGUSR1 received\n');
  collect_statistics();
}

void handleSigint(int sig)
{
  printf('SIGINT received\n');
  running = false;
  sendSignalToClients(SIGUSR2);
}

void handleSigusr2(int sig)
{
  printf('SIGUSR2 received\n');
  running = false;
}

void collectStatistics()
{
  for (int i = 0; i < numClients; i++)
  {
    kill(clients[i].pid, SIGUSR1);
  }
  usleep(1000000); // Подождем 1 секунду для сбора статистики

  // Чтение статистики из клиентских FIFO
  for (int i = 0; i < numClients; i++)
  {
    char statBuffer[BUFFER_SIZE];
    int fifo_fd = open(clients[i].fifoName, O_RDONLY | O_NONBLOCK);
    ssize_t bytesRead = read(fifo_fd, statBuffer, sizeof(statBuffer) - 1);
    if (bytesRead > 0)
    {
      statBuffer[bytesRead] = '\0';
      handleClientStatistic(statBuffer);
    }
    close(fifo_fd);
  }
}

void handleClientStatistic(const char *buffer)
{
  // Формат: PID: количество выражений
  pid_t pid;
  int count;
  sscanf(buffer, '%d: %d', &pid, &count);

  for (int i = 0; i < numClients; i++)
  {
    if (clients[i].pid == pid)
    {
      clients[i].expressionCount = count;
      break;
    }
  }
}

void finalStatistics()
{
  printf('Total amount:\n');
  for (int i = 0; i < numClients; i++)
  {
    printf('Client PID %d: count of expressions %d\n', clients[i].pid, clients[i].expressionCount);
  }
  printf('Server stopped.\n');
}
