## Build
```sh
docker build -t carcinogen75/openvpn .
```

## Usage
Run to see help...
```sh
docker run --rm carcinogen75/openvpn help
```
... or check out help.txt file

## Tips
* Comment out "comp-lzo" in server and client confs to speed up ur connection
* Check openvpn UDP server by command:
    ```sh
    $ echo -e "\x38\x01\x00\x00\x00\x00\x00\x00\x00" | timeout 10 nc -u myserver.com 1194 | cat -v
    ```
    If u see output like this...
    ```sh
    @$M-^HM--LdM-t|M-^X^@^@^@^@^@@$M-^HM--LdM-t|M-^X^@^@^@^@^@@$M-^HM--LdM-t|M-^X...
    ```
    ur server works fine

