# Compiler flags
CFLAGS := -w -m32 -D'main(a,b)=main(a,char**argv)'
DFLAGS := -g -O0

# Compile selfie.c into selfie executable
selfie: selfie.c
	$(CC) $(CFLAGS) $< -o $@

# Compile selfie.c into selfie executable include debug symbols
selfie_gdb: selfie.c
	$(CC) $(CFLAGS) $(DFLAGS) $< -o $@

# Consider these targets as targets, not files
.PHONY : test clean

# Test self-compilation, self-execution, and self-hosting
test: selfie
	./selfie -c selfie.c -o selfie1.m -s selfie1.s -m 2 -c selfie.c -o selfie2.m -s selfie2.s
	diff -q selfie1.m selfie2.m
	diff -q selfie1.s selfie2.s
	./selfie -c selfie.c -o selfie.m -m 2 -l selfie.m -m 1
	./selfie -c selfie.c -o selfie3.m -s selfie3.s -y 8 -l selfie3.m -y 4 -l selfie3.m -y 2 -c selfie.c -o selfie4.m -s selfie4.s
	diff -q selfie3.m selfie4.m
	diff -q selfie3.s selfie4.s
	diff -q selfie1.m selfie3.m
	diff -q selfie1.s selfie3.s

# Test self-compilation, self-execution, and self-hosting
short_test: selfie
	./selfie -c selfie.c -o selfie1.m -s selfie1.s -m 2 -c selfie.c -o selfie2.m -s selfie2.s
	diff -q selfie1.m selfie2.m
	diff -q selfie1.s selfie2.s

test_constant_folding: selfie
	echo "int main() { return 6 * 7 + 17;}" > test_constant_folding_1.tmp
	!(./selfie -c test_constant_folding_1.tmp -d 1 | grep -E 't[0-7]=6\s|t[0-7]=7\s|t[0-7]=17\s')
	./selfie -c test_constant_folding_1.tmp -d 1 | grep -E 'exit code 59'
	rm -f test_constant_folding_1.tmp
	echo "int main() { int x; x = -5; return x - 20 - 33 - 30 + 44;}" > test_constant_folding_2.tmp
	!(./selfie -c test_constant_folding_2.tmp -d 1 | grep -E 't[0-7]=-20\s|t[0-7]=-33\s|t[0-7]=-30\s|t[0-7]=44\s')
	./selfie -c test_constant_folding_2.tmp -d 1 | grep -E 'exit code -44'
	rm -f test_constant_folding_2.tmp
	echo "int main() { int x; x = -5; return 10 * 8 >> 2 + 2;}" > test_constant_folding_3.tmp
	!(./selfie -c test_constant_folding_3.tmp -d 1 | grep -E 't[0-7]=10\s|t[0-7]=8\s|t[0-7]=80\s|t[0-7]=2\s|t[0-7]=4\s')
	./selfie -c test_constant_folding_3.tmp -d 1 | grep -E 'exit code 5'
	rm -f test_constant_folding_3.tmp
	echo "int main() { int x; x = -5; return 10 * 8 - x + 2 + 2;}" > test_constant_folding_4.tmp
	!(./selfie -c test_constant_folding_4.tmp -d 1 | grep -E 't[0-7]=10\s|t[0-7]=8\s|t[0-7]=2\s')
	./selfie -c test_constant_folding_4.tmp -d 1 | grep -E 'exit code 89'
	rm -f test_constant_folding_4.tmp
	echo "int main() { int* x; *x = -5; return 10 * 8 - *x + 2 + 2;}" > test_constant_folding_5.tmp
	!(./selfie -c test_constant_folding_5.tmp -d 1 | grep -E 't[0-7]=10\s|t[0-7]=8\s|t[0-7]=2\s')
	./selfie -c test_constant_folding_5.tmp -d 1 | grep -E 'exit code 89'
	rm -f test_constant_folding_5.tmp
	echo "int main() { int* x; x = malloc(2 * 4); *(x + 1) = -5; return 10 * 8 - *(x + 1) + 2 + 2;}" > test_constant_folding_6.tmp
	!(./selfie -c test_constant_folding_6.tmp -d 1 | grep -E 't[0-7]=10\s|t[0-7]=8\s|t[0-7]=2\s')
	./selfie -c test_constant_folding_6.tmp -d 1 | grep -E 'exit code 89'
	rm -f test_constant_folding_6.tmp
	!(./selfie -c test/constant_folding_comparison.c -d 1 | grep -E 't[0-7]=5\s')
	./selfie -c test/constant_folding_comparison.c -d 1 | grep -E 'exit code 1'

# Test array functionality
test_arrays: selfie
	echo "int main() { int a[10]; int b[5]; a[0] = 23; a[1] = 24; b[3] = 7; return a[0] + a[1] + b[3];}" > test_arrays_1.tmp
	./selfie -c test_arrays_1.tmp -d 1 | grep -E 'exit code 54'
	rm -f test_arrays_1.tmp
	echo "int main() { int a[10]; int i; i = 0; while (i < 10) { a[i] = i; i = i + 1; } return a[9];}" > test_arrays_2.tmp
	./selfie -c test_arrays_2.tmp -d 1 | grep -E 'exit code 9'
	rm -f test_arrays_2.tmp
	./selfie -c test/array_stack.c -d 1 | grep -E 'exit code 63'
	./selfie -c test/array_global_vars.c -d 1 | grep -E 'exit code 12'
	./selfie -c test/array_access_expression.c -d 1 | grep -E 'exit code 209'
	./selfie -c test/array_heap.c -d 1 | grep -E 'exit code 73'
	./selfie -c test/array_pointer_arithmetic.c -d 1 | grep -E 'exit code 91'
	./selfie -c test/array_2d_local_vars.c -d 1 | grep -E 'exit code 68'
	./selfie -c test/array_2d_global_vars.c -d 1 | grep -E 'exit code 12'
	./selfie -c test/array_2d_assignment.c -d 1 | grep -E 'exit code 68'
	./selfie -c test/array_parameter.c -d 1 | grep -E 'exit code 30'
	./selfie -c test/array_function_argument.c -d 1 | grep -E 'exit code 30'

# Test struct functionality
test_struct: selfie
	./selfie -c selfie.c -o selfie1.m
	./selfie -c test/struct_global_declaration_1.c -o test/struct_global_declaration_1a.m -s test/struct_global_declaration_1a.s
	./selfie -l selfie1.m -m 2 -c test/struct_global_declaration_1.c -o test/struct_global_declaration_1b.m -s test/struct_global_declaration_1b.s
	diff -q test/struct_global_declaration_1a.m test/struct_global_declaration_1b.m
	diff -q test/struct_global_declaration_1a.s test/struct_global_declaration_1b.s
	./selfie -c test/struct_global_declaration_2.c
	./selfie -c test/struct_global_declaration_2.c -o test/struct_global_declaration_2a.m -s test/struct_global_declaration_2a.s
	./selfie -l selfie1.m -m 2 -c test/struct_global_declaration_2.c -o test/struct_global_declaration_2b.m -s test/struct_global_declaration_2b.s
	diff -q test/struct_global_declaration_2a.m test/struct_global_declaration_2b.m
	diff -q test/struct_global_declaration_2a.s test/struct_global_declaration_2b.s
	./selfie -c test/struct_local_declaration.c
	./selfie -c test/struct_local_declaration.c -o test/struct_local_declarationa.m -s test/struct_local_declarationa.s
	./selfie -l selfie1.m -m 2 -c test/struct_local_declaration.c -o test/struct_local_declarationb.m -s test/struct_local_declarationb.s
	diff -q test/struct_global_declaration_1a.m test/struct_global_declaration_1b.m
	diff -q test/struct_global_declaration_1a.s test/struct_global_declaration_1b.s
	./selfie -c test/struct_pointer_function_argument.c
	./selfie -c test/struct_pointer_function_argument.c -o test/struct_pointer_function_argumenta.m -s test/struct_pointer_function_argumenta.s
	./selfie -l selfie1.m -m 2 -c test/struct_pointer_function_argument.c -o test/struct_pointer_function_argumentb.m -s test/struct_pointer_function_argumentb.s
	diff -q test/struct_pointer_function_argumenta.m test/struct_pointer_function_argumentb.m
	diff -q test/struct_pointer_function_argumenta.s test/struct_pointer_function_argumentb.s
	./selfie -c test/struct_pointer_to_struct.c
	./selfie -c test/struct_pointer_to_struct.c -o test/struct_pointer_to_structa.m -s test/struct_pointer_to_structa.s
	./selfie -l selfie1.m -m 2 -c test/struct_pointer_to_struct.c -o test/struct_pointer_to_structb.m -s test/struct_pointer_to_structb.s
	diff -q test/struct_pointer_to_structa.m test/struct_pointer_to_structb.m
	diff -q test/struct_pointer_to_structa.s test/struct_pointer_to_structb.s
	./selfie -c test/struct_access_assignment1.c
	./selfie -c test/struct_access_assignment1.c -o test/struct_access_assignment1a.m -s test/struct_access_assignment1a.s
	./selfie -l selfie1.m -m 2 -c test/struct_access_assignment1.c -o test/struct_access_assignment1b.m -s test/struct_access_assignment1b.s
	diff -q test/struct_access_assignment1a.m test/struct_access_assignment1b.m
	diff -q test/struct_access_assignment1a.s test/struct_access_assignment1b.s
	rm -rf test/*.s
	rm -rf test/*.m

test_all: selfie
	make test_constant_folding
	make test_arrays
	make -C test/struct

# Clean up
clean:
	rm -rf *.m
	rm -rf *.s
	rm -rf selfie
	rm -rf test/*.s
	rm -rf test/*.m
