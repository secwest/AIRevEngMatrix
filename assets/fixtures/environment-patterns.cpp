#include <iostream>
#include <stdexcept>
#include <string>

struct Transform {
    virtual int apply(int value) const = 0;
    virtual ~Transform() = default;
};

struct Add final : Transform {
    int amount;
    explicit Add(int n) : amount(n) {}
    int apply(int value) const override {
        if (value > 255 - amount) throw std::runtime_error("overflow");
        return value + amount;
    }
};

template <class T> int invoke(const T& operation, int value) {
    return operation.apply(value);
}

int main(int argc, char** argv) {
    try {
        if (argc < 2) throw std::runtime_error("missing");
        const std::string input(argv[1]);
        if (input.empty() || input.find_first_not_of("0123456789") != std::string::npos)
            throw std::runtime_error("invalid");
        int value;
        try { value = std::stoi(input); }
        catch (const std::exception&) { throw std::runtime_error("invalid"); }
        if (value > 255) throw std::runtime_error("invalid");
        const Add operation(7);
        const Transform& erased = operation;
        const int result = invoke(erased, value);
        std::cout << "ok:" << result << '\n';
    } catch (const std::runtime_error& error) {
        std::cout << "err:" << error.what() << '\n';
    }
}
