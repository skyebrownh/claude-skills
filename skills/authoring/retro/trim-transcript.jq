# Trims a Claude Code session transcript (.jsonl) to what /retro's reader needs:
# Skye's messages, text that started a turn without her (labelled SESSION),
# Claude's text, each tool call in short, and failed tool results (a refused or
# failed call is often where something went wrong).
# Each output line starts with its line number in the .jsonl, so a finding can
# point back to the full record.
#
# Usage: jq -r -f trim-transcript.jq <session>.jsonl > trimmed.txt

# Long text is cut, because the reader needs the gist, not every word. Messages
# keep the most (2000 characters), since corrections live there; a failed
# result keeps enough for its error (300), and a tool call its target (200).
def clip(n): if length > n then .[0:n] + " […]" else . end;

input_line_number as $n
# Each record's .type is who wrote it (user, assistant, or app bookkeeping).
# isMeta marks text the app adds on the user's side, such as a loaded skill.
| if .type == "user" and (.isMeta | not) then
    # turnOrigin says who started the turn: "human" for Skye, and something
    # else for a turn she didn't start, such as "sdk" for the brief another
    # Claude session writes when it starts this one. A record without it (older
    # transcripts, and some app notices) counts as hers, as it always has.
    (if (.turnOrigin // "human") == "human" then "SKYE" else "SESSION" end) as $who
    # A typed message is a string; tool results and some messages are a list of
    # blocks. From here on, .type is the block's type (text, tool_result, tool_use).
    | (if (.message.content | type) == "string" then [{type: "text", text: .message.content}] else .message.content end)[]
    | if .type == "text"
         # System reminders are the app's notes, not Skye's words.
         and (.text | startswith("<system-reminder>") | not)
         # A compaction summary repeats lines that are already earlier in the file.
         and (.text | startswith("This session is being continued") | not)
      then "\($n) \($who): \(.text | clip(2000))"
      elif .type == "tool_result" and .is_error == true then "\($n) TOOL FAILED: \(.content | tostring | clip(300))"
      else empty end
  elif .type == "assistant" then
    .message.content[]
    | if .type == "text" then "\($n) CLAUDE: \(.text | clip(2000))"
      elif .type == "tool_use" then "\($n) TOOL \(.name): \(.input | tostring | clip(200))"
      else empty end
  else empty end
