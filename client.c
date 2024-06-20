#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <signal.h>
#include <string.h>
#include <errno.h>
#include <ctype.h>

#define SERVER_FIFO "/tmp/my_fifo"
#define CLIENT_FIFO_TEMPLATE "/tmp/client.%d.fifo"
#define BUFFER_SIZE 256

int serverFifoFd;
char clientFifo[BUFFER_SIZE];
int clientFifoFd;
pid_t pid;
int expressionCount = 0;

void handleSigusr1(int sig);
void handleSigusr2(int sig);
void sendStatistics();
void finalResult();
void countExpressions(const char *data);

int main(int argc, char *argv[])
{
  char buffer[BUFFER_SIZE];

  // Определение пути к FIFO сервера
  const char *serverFifoPath = (argc > 1) ? argv[1] : SERVER_FIFO;

  // Определение PID и создание уникального FIFO для клиента
  pid = getpid();
  snprintf(clientFifo, sizeof(clientFifo), CLIENT_FIFO_TEMPLATE, pid);

  if (mkfifo(clientFifo, 0666) == -1)
  {
    perror("Error create client FIFO");
    return 1;
  }

  // Открытие FIFO сервера для записи
  serverFifoFd = open(serverFifoPath, O_WRONLY);
  if (serverFifoFd == -1)
  {
    perror("Error create FIFO server");
    unlink(clientFifo);
    return 1;
  }

  // Отправка серверу PID для регистрации
  snprintf(buffer, sizeof(buffer), "%d", pid);
  write(serverFifoFd, buffer, strlen(buffer) + 1);
  close(serverFifoFd);

  // Установка обработчиков сигналов
  signal(SIGUSR1, handleSigusr1);
  signal(SIGUSR2, handleSigusr2);

  // Открытие клиентского FIFO для чтения
  clientFifoFd = open(clientFifo, O_RDONLY);
  if (clientFifoFd == -1)
  {
    perror("Error open client FIFO");
    unlink(clientFifo);
    return 1;
  }

  // Основной цикл ожидания данных от сервера
  while (1)
  {
    ssize_t bytes_read = read(clientFifoFd, buffer, sizeof(buffer) - 1);
    if (bytes_read > 0)
    {
      buffer[bytes_read] = '\0';
      countExpressions(buffer);
    }
  }

  close(clientFifoFd);
  unlink(clientFifo);

  return 0;
}

void countExpressions(const char *data)
{
  int count = 0;
  const char *ptr = data;
  while (*ptr)
  {
    if (ispunct(*ptr) && !ispunct(*(ptr + 1)) && *(ptr + 1) != '\0')
    {
      count++;
    }
    ptr++;
  }
  expressionCount += count;
}

void handleSigusr1(int sig)
{
  send_statistics();
}

void handleSigusr2(int sig)
{
  final_result();
  close(clientFifoFd);
  unlink(clientFifo);
  exit(0);
}

void sendStatistics()
{
  char buffer[BUFFER_SIZE];
  serverFifoFd = open(SERVER_FIFO, O_WRONLY);
  if (serverFifoFd == -1)
  {
    perror("Error open FIFO server for sending statistics");
    return;
  }
  snprintf(buffer, sizeof(buffer), "%d: %d", pid, expressionCount);
  write(serverFifoFd, buffer, strlen(buffer) + 1);
  close(serverFifoFd);
}

void finalResult()
{
  sendStatistics();
}
