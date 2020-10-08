# Prolog Parser
Parser for a simplified version of Prolog.


<details>
<summary>
    Linux (U)buntu
</summary>

* Elixir install:
```
wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb && sudo dpkg -i erlang-solutions_2.0_all.deb
sudo apt-get update
sudo apt-get install esl-erlang
sudo apt-get install elixir
```

* Prolog Parser build:
```
mix escript.build
```
</details>

<details>
<summary>
    MacOS
</summary>

* Elixir install:
```
brew install elixir
```

* Prolog Parser build:
```
mix escript.build
```
</details>

Usage:
```
./prolog_parser -f file.txt
```
