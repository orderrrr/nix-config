function ai-commit --description "Auto-generate commit message using Ollama"
    set -l model "SimonPu/Qwen3-Coder:30B-Instruct_Q4_K_XL"
    set -l vcs ""
    set -l diff_output ""

    # Detect version control system
    if command -q jj; and jj root >/dev/null 2>&1
        set vcs "jj"
        set diff_output (jj diff)
    else if command -q git; and git rev-parse --git-dir >/dev/null 2>&1
        set vcs "git"
        set diff_output (git diff --cached)
        if test -z "$diff_output"
            set diff_output (git diff)
        end
    else
        echo "Error: Not in a jj or git repository"
        return 1
    end

    if test -z "$diff_output"
        echo "Error: No changes detected"
        return 1
    end

    echo "Generating commit message with Ollama..."

    # Build prompt for Ollama
    set -l prompt "Write a concise git commit message for the following diff. Use conventional commit format (feat:, fix:, refactor:, docs:, etc). Be specific but brief. Output ONLY the commit message, nothing else. No explanations, no markdown, just the message.

Diff:
$diff_output"

    # Call Ollama and extract response
    set -l message (echo $prompt | ollama run $model 2>/dev/null | string collect)

    if test -z "$message"
        echo "Error: Failed to generate commit message"
        return 1
    end

    # Clean up the message - remove any thinking tags or extra whitespace
    set message (echo $message | string replace -ra '<think>.*</think>' '' | string trim)

    echo "Generated message:"
    echo "---"
    echo $message
    echo "---"

    # Apply the commit/description
    if test "$vcs" = "jj"
        jj describe -m "$message"
        echo "Description set with jj"
    else
        # For git, stage all changes if nothing staged
        if test -z "$(git diff --cached)"
            read -l -P "No staged changes. Stage all changes? [y/N] " confirm
            if test "$confirm" = "y" -o "$confirm" = "Y"
                git add -A
            else
                echo "Aborted"
                return 1
            end
        end
        git commit -m "$message"
        echo "Committed with git"
    end
end
