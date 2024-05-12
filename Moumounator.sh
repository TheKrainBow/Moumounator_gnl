source settings.sh

if ! test -d "outputs"; then
	mkdir "outputs"
fi

if [ -n "$(ls -A outputs/)" ]; then
	rm -rf outputs/*
fi
TOTAL_SUCCESS=0
TOTAL_TESTS=0

PATH_TO_PROJECT=$(echo $PATH_TO_PROJECT | sed "s/\/$//")
cp $PATH_TO_PROJECT/get_next_line.c $PATH_TO_PROJECT/get_next_line_utils.c $PATH_TO_PROJECT/get_next_line.h ./libs 2> /dev/null
cp $PATH_TO_PROJECT/get_next_line_bonus.c $PATH_TO_PROJECT/get_next_line_utils_bonus.c $PATH_TO_PROJECT/get_next_line_bonus.h ./libs 2> /dev/null

BUFFER_SIZES=(1 2 3 42 10000)

for BUFFER_SIZE in ${BUFFER_SIZES[@]}
do
	echo "BUFFER_SIZE $BUFFER_SIZE:"
	for FILE_NAME in $(find files/ -mindepth 1 -maxdepth 1 -type f | sed "s/.*\///" | sort)
	do
		len=15
		len=$(($len-${#FILE_NAME}))
		printf " -> $FILE_NAME"
		while [ 0 -le $len ]
		do
			printf " "
			len=$(( $len - 1 ))
		done
		printf "[ ]\b\b"
		source scripts/start_test.sh
	done
	echo
done

if [ $TOTAL_SUCCESS == $TOTAL_TESTS ]; then
	printf "\n\033[32;1;1m╭───────────────────────────────╮\n"
	printf "│\033[0m %3d/%-3d tests                 \033[32;1;1m│\n" $TOTAL_SUCCESS $TOTAL_TESTS
	printf "│\033[0m Everything is good for me! :) \033[32;1;1m│\n"
	printf "╰───────────────────────────────╯\033[0m\n"
else
	printf "\n\033[31;1;1m╭───────────────────────────────╮\n"
	printf "│\033[0m %3d/%-3d tests                 \033[31;1;1m│\n" $TOTAL_SUCCESS $TOTAL_TESTS
	printf "│\033[0m Check outputs for details :(  \033[31;1;1m│\n"
	printf "╰───────────────────────────────╯\033[0m\n"
fi
