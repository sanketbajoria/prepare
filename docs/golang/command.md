
# Quick command

## Compile and execute the go files
go run "list of go file" // it will compile and run the go language
```go
go run main.go hello.go
go run .
```

## Compile and Create a executable from go file
go build "list of go file" // Create a executable file
It will create executable in current directory
```go
go build main.go hello.go
go build .
```

## Compile and Install a executable from go file to $GOBIN path
go install "list of go file" // Create a executable file
It will create executable in $GOBIN directory
```go
go install main.go hello.go
go install .
```

## Print environment variable
go env "Environment variable" //Print env variable
```go
go env "GOPATH"
```

## Fetch go doc
Internally it calls **godoc** command 

```go
go doc "packageName" "MethodName"

go doc -src "packageName" "MethodName"


go doc fmt Println
go doc -src fmt Prinln

```

## Get Go Package
It will add package to go.mod file. (similar to npm install)
```go
go get <package full path>
```


## Get Go version
```go
go version
```