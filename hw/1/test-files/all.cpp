#include <fstream>

int main(int, const char*[])
{
    std::ofstream out("all.dat");

    for (int i = 0; i < 256; ++i) {
        char c = static_cast<char>(i);
        out << c;
    }

    return 0;
}
