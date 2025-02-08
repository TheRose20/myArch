https://www.howtogeek.com/248780/how-to-compress-and-extract-files-using-the-tar-command-on-linux/

# Import
## Simple
```
tar -czvf name-of-archive.tar.gz /path/to/directory-or-file
```
- c: Create an archive
- z: Compress the archive with gzip
- v: display progress it the terminal while creating the archive, also knows as "verbose" mode
- f: Allows you to specify the filename of the arhive

## Multiple directories
```
tar -czvf archive.tar.gz /home/ubuntu/Downloads /usr/local/stuff /home/ubuntu/Documents/notes.txt
```
Just list as many directories or files as you want to back up.

## Exclude directories and files
```
tar -czvf archive.tar.gz /home/ubuntu --exclude=/home/ubuntu/Downloads --exclude=/home/ubuntu/.cache
```

```
tar -czvf archive.tar.gz /home/ubuntu --exclude=*.mp4
```

### bzip

```
tar -cjvf archive.tar.bz2 stuff
```

# Extract
```
tar -xzvf archive.tar.gz
```

## with path
```
tar -xzvf archive.tar.gz -C /tmp
```