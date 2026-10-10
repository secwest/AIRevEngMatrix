package main

import (
	"errors"
	"fmt"
	"os"
	"strconv"
)

type transform interface{ apply(int) (int, error) }
type add struct{ amount int }

func (a add) apply(value int) (int, error) {
	if value > 255-a.amount {
		return 0, errors.New("overflow")
	}
	return value + a.amount, nil
}
func evaluate(args []string) (int, error) {
	if len(args) == 0 {
		return 0, errors.New("missing")
	}
	value, err := strconv.ParseUint(args[0], 10, 8)
	if err != nil {
		return 0, errors.New("invalid")
	}
	var operation transform = add{7}
	closure := func() (int, error) { return operation.apply(int(value)) }
	return closure()
}
func main() {
	defer func() { fmt.Print("cleanup\n") }()
	value, err := evaluate(os.Args[1:])
	if err != nil {
		fmt.Println("err:" + err.Error())
		return
	}
	fmt.Printf("ok:%d\n", value)
}
