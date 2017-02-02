# Speedyrails ZenDesk Publishing Scripts

## What is this toolset, and why does it exist?

ZenDesk does not include version control in its help center. To fix this, we've created a tool to locally create markdown files for our help center and maintain version control for documentation as our product changes and evolves. Doing so maintains data integrity and will ultimately add to the IX goals of the company.

## What does it do?

1. Lists current sections in a help center
2. Publishes markdown files to a help center via API (using [github/markup](https://github.com/github/markup))

## Important Notes

`docscli.rb` uses API token authentication. Make sure that your credentials point to `/token`
`sandbox.rb` uses basic User/Password authentication.

Both scripts require the full path to the file. To get a full path, navigate to the file directory in your terminal and type `pwd`.

## Usage

**List sections in a help center**

`ruby sandbox.rb sections`
`ruby docscli.rb sections`

**Publish a document to a help center**

`ruby sandbox.rb publish --file=/Users/.../docs/path/to/doc.md` -
`ruby docscli.rb publish --file=/Users/.../docs/path/to/doc.md`
