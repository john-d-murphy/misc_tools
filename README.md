## Personal Tools

Miscellaneous shell and python scripts. May be useful to others so I'm sharing here. Summaries of
the tools are AI generated, so please excuse any weird formality and/or plastic tone in the
summaries.

### summarize_code.sh

**Summary**
This Bash script summarizes a given code file by sending its contents to the OpenAI Chat Completions API, expecting a small JSON response, and rendering that response as a Markdown snippet either to stdout or appended to a specified output file, after performing basic argument and environment validation.

**Usage**
```bash
./summarize_code.sh path/to/code_file.sh [output.md]
```

### n

**Summary**
This Bash script is a CLI tool for quickly creating Markdown notes with YAML front matter, tags, timestamps, and optional editing, saving them into a dated directory structure under a configurable notes inbox folder.

**Usage**
```bash
n -t idea,work -n "My quick thought" "This is the body of the note"
```

### get_youtube_channel_id.py

**Summary**
This script takes a YouTube channel handle, fetches the channel page HTML, extracts the channel’s unique Channel ID using a regex, and prints both the Channel ID and its corresponding RSS feed URL for use in RSS readers like newsboat.

**Usage**
```bash
python get_youtube_channel_id.py <youtube_channel_handle>
```

### pick_license.sh

**Summary**
This Bash script uses the GitHub CLI to list available open-source licenses, lets you interactively choose one, prompts for copyright year and holder name, fills in the template placeholders, and writes the resulting license text to a LICENSE file in the current repository.

**Usage**
```bash
bash pick-license.sh
```

### weather.sh

**Summary**
This Bash script periodically clears the terminal and displays the weather from wttr.in at specific times of day (06:00, 09:00, 12:00, 15:00, 18:00), looping indefinitely and calculating the next scheduled run based on the current time.

**Usage**
```bash
bash weather.sh
```
### cal.sh

**Summary**
This Bash script repeatedly clears the terminal and runs `gcalcli calw` to display a weekly calendar, refreshing exactly at the top of every hour indefinitely, handling failures without exiting.

**Usage**
```bash
bash cal.sh
```

### d

**Summary**
This Bash script provides a colorized command-line dictionary/thesaurus client for dict.org, defaulting to WordNet, with options to query specific databases, search all, or list available databases, using the dict client or curl as a fallback.

**Usage**
```bash
./def example_word thes
```
