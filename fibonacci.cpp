#include <iostream>

using namespace std;

int main()
{
    int fibo0 = 0;
    int fibo1 = 1;
    int count = 5;
    count--;
    // 0 1 1 2 3 5 8 13
    while (count > 0)
    {
        int current = fibo0 + fibo1;
        fibo0 = fibo1;
        fibo1 = current;
        count = count - 1;
    }
    cout << fibo1 << endl;

    return 0;
}