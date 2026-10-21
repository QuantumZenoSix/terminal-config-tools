# Postboy
Little wrapper for Curl for making simple API requests. (json)  
Not something I would regularly use, but a handy tiny script I can whip out in the CLI if I want to test a quick API call.

## Usage
```
postboy.sh
```

<br />

You can optionally specify a URL, endpoint, and HTTP method as a script argument as well.
```
postboy.sh -u {URL} -e {endpoint} -m GET
```


<br />

<br />

_Note: Requests default to GET if no method specific

<br />

### Authentication and Headers
If you have a JWT Bearer Token to set or some headers, they must be specified as a script argument.
```bash
postboy.sh -b {BEARER_TOKEN} -h {HEADER}
```

<br />

You can set up to 4 headers using the `h` to `k` flags:
```bash
postboy.sh -b {BEARER_TOKEN} -h {HEADER} -i {HEADER2} -j {HEADER3} -k {HEADER4} 
```

<br />

### Examples
![Example2](https://github.com/bobby-valenzuela/Postboy/blob/main/sample2.png?raw=true)
![Example1](https://github.com/bobby-valenzuela/Postboy/blob/main/sample1.png?raw=true)



<br />

### Known Issues
When making POST request and sending a request body, one-liner JSON works fine `{"type":"example"}` but multi-line JSON causes issues as bash can't read the carriage return.
