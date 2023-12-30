import sys
import os

# import validators

if len(sys.argv) > 1:
    inputfilepath = sys.argv[1]
else:
    print("No files were given")
    exit(1)


def domain_key_function(s):
    # Turn "www.google.com" into ["www", "google", "com"], then
    # reverse it to ["com", "google", "www"].
    return list(reversed(s["domain"].split(".")))


allDomains = []


def alldomainseval(domain):
    if domain not in allDomains:
        allDomains.append(domain)
    else:
        print("Warning: Found Duplicate across sections:", domain)


def sortdomains(ddl):
    newlist = sorted(ddl, key=domain_key_function)
    index = 1
    alldomainseval(newlist[0]["domain"])
    while index < len(newlist):
        if newlist[index]["domain"] == newlist[index - 1]["domain"]:
            print("Warning: Joining expressions:")
            print(formatline(newlist[index - 1]), end="")
            print(formatline(newlist[index]), end="")
            newlist[index - 1]["endcomment"] += newlist[index]["endcomment"]
            newlist[index - 1]["isCommentToggled"] &= newlist[index]["isCommentToggled"]
            newlist.pop(index)
        else:
            alldomainseval(newlist[index]["domain"])
            index += 1
    return newlist


def evalLine(line):
    line = line.strip()
    isCommentToggled = False
    if line.startswith("!"):
        isCommentToggled = True
        line = line[1:].strip()
    endcomment = ""
    if "#" in line:
        parts = line.split("#", 1)
        endcomment = parts[1].strip()
        line = parts[0].strip()
    # if not validators.domain(line):
    #    print('Warning: "' + line + '" is not a valid domain')
    domain = line
    return {
        "domain": domain,
        "isCommentToggled": isCommentToggled,
        "endcomment": endcomment,
    }


def formatline(dictline):
    line = ""
    if dictline["isCommentToggled"]:
        line += "! "
    line += dictline["domain"]
    if dictline["endcomment"]:
        line += " # " + dictline["endcomment"]
    return line + "\n"


def isComment(line):
    return line.strip().startswith("#")


infile = open(
    inputfilepath,
    "r",
)
outfile = open(
    inputfilepath + ".tmp",
    "w",
)
nonCommentBuffer = []
while True:
    line = infile.readline()
    if not line:
        if len(nonCommentBuffer) > 0:
            for dictline in sortdomains(nonCommentBuffer):
                outfile.write(formatline(dictline))
        break
    elif not line.strip():
        continue
    elif isComment(line):
        if len(nonCommentBuffer) > 0:
            for dictline in sortdomains(nonCommentBuffer):
                outfile.write(formatline(dictline))
            nonCommentBuffer = []
            outfile.write("\n")
        outfile.write(line)
    else:
        nonCommentBuffer.append(evalLine(line))

infile.close()
outfile.close()
os.replace(inputfilepath + ".tmp", inputfilepath)
