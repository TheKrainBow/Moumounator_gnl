DAY_NUMBER=$1
DAY_PATH=$2

if ! test -d "outputs/$BUFFER_SIZE/"; then
	mkdir "outputs/$BUFFER_SIZE/"
fi

if ! test -d "outputs/$BUFFER_SIZE/$FILE_NAME"; then
	mkdir "outputs/$BUFFER_SIZE/$FILE_NAME"
fi

OUTPUT_PATH="outputs/$BUFFER_SIZE/$FILE_NAME"

NUMBER_OF_SUCCESS=0
NUMBER_OF_TESTS=0

test_function()
{
	# Compile test with working library
	cc ./tests/main.c libs/Moumounator.a -D BUFFER_SIZE="$BUFFER_SIZE" -Ilibs -o $OUTPUT_PATH/answer.out
	if [ $? -ne 0 ]; then
		return
	fi
	# Compile test with user library
	cc -Wall -Wextra -Werror -fsanitize=address -g -D BUFFER_SIZE=$BUFFER_SIZE ./tests/main.c libs/get_next_line_utils.c libs/get_next_line.c -Ilibs -o $OUTPUT_PATH/user.out 2> $OUTPUT_PATH/user.compilation_error.out
	if [ $? -ne 0 ]; then
		printf "\033[31;1;1m✗ \033[0m"
		rm ./$OUTPUT_PATH/answer.out
		NUMBER_OF_TESTS=$(($NUMBER_OF_TESTS + 1))
		return
	else
		rm $OUTPUT_PATH/user.compilation_error.out
	fi
	# Execute both executable and redirect outputs in txt files
	./$OUTPUT_PATH/answer.out ./files/$FILE_NAME > $OUTPUT_PATH/answer.txt
	timeout 3 ./$OUTPUT_PATH/user.out ./files/$FILE_NAME > $OUTPUT_PATH/user.txt 2> $OUTPUT_PATH/user_errors.txt
	if [ $? -eq 124 ]; then
		printf "\033[31;1;1m✗\033[0m] \033[3m\033[31;1;1mTimeout!\033[0m\n"
		printf "Timed out after 3 secondes!" > $OUTPUT_PATH/user_errors.txt
		if [[ -z $(grep '[^[:space:]]' $OUTPUT_PATH/user_errors.txt) ]]; then
			rm $OUTPUT_PATH/user_errors.txt
		fi
		NUMBER_OF_TESTS=$(($NUMBER_OF_TESTS + 1))
		rm ./$OUTPUT_PATH/answer.out ./$OUTPUT_PATH/user.out
		return
	fi
	if [[ -z $(grep '[^[:space:]]' $OUTPUT_PATH/user_errors.txt) ]]; then
		rm $OUTPUT_PATH/user_errors.txt
	fi
	rm ./$OUTPUT_PATH/answer.out ./$OUTPUT_PATH/user.out
	# Diff the txt files
	diff $OUTPUT_PATH/answer.txt $OUTPUT_PATH/user.txt > $OUTPUT_PATH/diff.txt
	if [ $? -eq 1 ] || [ -s "$OUTPUT_PATH/user_errors.txt" ]; then
		printf "\033[31;1;1m✗\033[0m]\n"
	else
		printf "\033[32;1;1m✓\033[0m]\n"
		NUMBER_OF_SUCCESS=$(($NUMBER_OF_SUCCESS + 1))
		if [ $RM_ON_SUCCESS -ne 0 ]; then
			rm -r $OUTPUT_PATH
		fi
	fi
	NUMBER_OF_TESTS=$(($NUMBER_OF_TESTS + 1))
}

test_function
wait
# if [ $NUMBER_OF_SUCCESS == $NUMBER_OF_TESTS ]; then
# 	print_result $(find $DAY_PATH/$DAY_NUMBER/ -mindepth 1 -type f -name "*.c" | sed "s/.*\/test//" | sed "s/_.*//" | wc -l)
# else
# 	print_result $(find $DAY_PATH/$DAY_NUMBER/ -mindepth 1 -type f -name "*.c" | sed "s/.*\/test//" | sed "s/_.*//" | wc -l)
# fi

if [ -z "$(ls -A outputs/$BUFFER_SIZE/)" ]; then
	rm -rf outputs/$BUFFER_SIZE/
fi

if [ -z "$TOTAL_SUCCESS" ]; then
	TOTAL_SUCCESS=$NUMBER_OF_SUCCESS
else
	TOTAL_SUCCESS=$(($TOTAL_SUCCESS + $NUMBER_OF_SUCCESS))
fi

if [ -z "$TOTAL_TESTS" ]; then
	TOTAL_TESTS=$NUMBER_OF_TESTS
else
	TOTAL_TESTS=$(($TOTAL_TESTS + $NUMBER_OF_TESTS))
fi