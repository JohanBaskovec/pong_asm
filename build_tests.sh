nasm -f elf64 -g -F dwarf -l pong_tests.lst pong_tests.asm


if [ $? -eq 0 ]; then
    clang -g -o pong_tests pong_tests.o `sdl2-config --cflags --libs` -lGLEW -lGLU -lGL -lm

    if [ $? -eq 0 ]; then
        chmod +x ./pong_tests
        exit 0
    else
        exit 1
    fi
else
    exit 1
fi
