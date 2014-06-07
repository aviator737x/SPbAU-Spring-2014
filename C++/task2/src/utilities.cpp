#include "utilities.hpp"

size_t utilities::write(ofstream &file, string const &s)
{
    size_t position = file.tellp();
    write(file, s.size());
    file.write(s.c_str(), s.size());
    return position;
}

void utilities::write(ofstream &file, size_t n)
{
    file.write(reinterpret_cast<char const *>(&n), sizeof(n));
}

size_t utilities::read(ifstream &file)
{
    size_t n;
    file.read(reinterpret_cast<char *>(&n), sizeof(n));
    return n;
}

string utilities::read_string(ifstream &file)
{
    size_t n = read(file);
    char *buffer = new char[n + 1]{};
    file.read(buffer, n);
    return string(buffer);
}