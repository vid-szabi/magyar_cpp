#include <iostream>

using namespace std;

int main() {
    int fibo0 = 0;
    int fibo1 = 1;
    int count;
    cin >> count;
    count = (count - 1);
    while ((count != 0)) {
        int jelenlegi = (fibo0 + fibo1);
        fibo0 = fibo1;
        fibo1 = jelenlegi;
        count = (count - 1);
        cout << jelenlegi << endl;
    }

    return 0;
}
