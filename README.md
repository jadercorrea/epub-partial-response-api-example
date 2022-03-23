# EpubApi

Sample API to test range requests implementation for epub files. Used during
no-need-for-phoenix and beer-n-code sessions.

## Installation & Running

```bash
mix deps.get
iex -S mix
```
You'll be able to test the implementation by using cURL:

```
curl http://localhost:4000/book\?isbn\=123 -H "Range: bytes=0-4096" --output 123-partial.epub
```
