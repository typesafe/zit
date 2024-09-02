<p><a target="_blank" href="https://app.eraser.io/workspace/QOW47W3nLNkigPzSzJXk" id="edit-in-eraser-github-link"><img alt="Edit in Eraser" src="https://firebasestorage.googleapis.com/v0/b/second-petal-295822.appspot.com/o/images%2Fgithub%2FOpen%20in%20Eraser.svg?alt=media&amp;token=968381c8-a7e7-472a-8ed6-4a6626da5501"></a></p>

This is a starting point for Zig solutions to the
[﻿"Build Your Own Git" Challenge](https://codecrafters.io/challenges/git).

![Figure 2](/.eraser/QOW47W3nLNkigPzSzJXk___fHNVyjOTUFgRZBn5Q9cYoAfuESw1___---figure---iHoYfhJW8ROEKKJ45PqmB---figure---SlHpUb5leLCDdjLqMC4L-g.png "Figure 2")

In this challenge, you'll build a small Git implementation that's capable of
initializing a repository, creating commits and cloning a public repository.
Along the way we'll learn about the `.git` directory, Git objects (blobs,
commits, trees etc.), Git's transfer protocols and more.

**Note**: If you're viewing this repo on GitHub, head over to
[﻿codecrafters.io](https://codecrafters.io/) to try the challenge.

![Figure 1](/.eraser/QOW47W3nLNkigPzSzJXk___fHNVyjOTUFgRZBn5Q9cYoAfuESw1___---figure---Q6mFGsZyzUz8kEJp94FlD---figure---jgKg8DYNmpiZ8M1tmu6SKw.png "Figure 1")

# Passing the first stage
The entry point for your Git implementation is in `src/main.zig`. Study and
uncomment the relevant code, and push your changes to pass the first stage:

```sh
git add .
git commit -m "pass 1st stage" # any msg
git push origin master
```
That's all!

# Stage 2 & beyond
Note: This section is for stages 2 and beyond.

1. Ensure you have `zig (0.12)`  installed locally
2. Run `./your_git.sh`  to run your Git implementation, which is implemented in
`src/main.zig` .
3. Commit your changes and run `git push origin master`  to submit your solution
to CodeCrafters. Test output will be streamed to your terminal.
# Testing locally
The `your_git.sh` script is expected to operate on the `.git` folder inside the
current working directory. If you're running this inside the root of this
repository, you might end up accidentally damaging your repository's `.git`
folder.

We suggest executing `your_git.sh` in a different folder when testing locally.
For example:

```sh
mkdir -p /tmp/testing && cd /tmp/testing
/path/to/your/repo/your_git.sh init
```
To make this easier to type out, you could add a
[﻿shell alias](https://shapeshed.com/unix-alias/):

```sh
alias mygit=/path/to/your/repo/your_git.sh

mkdir -p /tmp/testing && cd /tmp/testing
mygit init
```




<!--- Eraser file: https://app.eraser.io/workspace/QOW47W3nLNkigPzSzJXk --->