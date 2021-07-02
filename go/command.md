
# Quick command

## Compile and execute the go files
go run "list of go file" // it will compile and run the go language
```
go run main.go hello.go
go run .
```

## Compile and Create a executable from go file
go build "list of go file" // Create a executable file
```
go build main.go hello.go
go build .
```

## Print environment variable
go env "Environment variable" //Print env variable
```
go env "GOPATH"
```

## Fetch go doc
Internally it calls **godoc** command 

go doc "packageName" "MethodName"

go doc -src "packageName" "MethodName"

```
go doc fmt Println
go doc -src fmt Prinln
```