import osproc, os, strutils
import illwill
import math
import sequtils

#Initialise terminal in fullscreen mode and make sure we restore the state
proc exitProc() {.noconv.} =
    illwillDeinit()
    showCursor()
    quit(0)

illwillInit(fullscreen = true)
setControlCHook(exitProc)
hideCursor()

var tb = newTerminalBuffer(terminalWidth(), terminalHeight())

while true:

    #absolute gigachad cpu usage reapropriated from lyriah
    proc getCpuUsage(): string =
        let firstLine = "/proc/stat".readLines(1)[0]
        let vals = firstline.splitWhitespace()[1..^1].map(parseInt)
        let totalTime = sum(vals)
        let notIdlePerc = (1 - (vals[3] / totalTime)) * 100
        return $(round(notIdlePerc, 1)) & "%\n"
    var cpusage = getCpuUsage()

    #declare the commands you want to use (shamelessley stolen from lyriah)
    var usedmem = execProcess("printf \"%s/%s\n\" \"$(free -h | sed -n '2p' | awk '{print $3}')\" \"$(free -h | sed -n '2p' | awk '{print $2}')\"")
    var shell = execProcess("basename $(echo $SHELL)")
    var clear = execProcess("clear")
    var username = getEnv("USER")
    var hostname = execProcess("hostname")
    var distroname = execProcess("cat /etc/os-release | grep -oP \"(?<=^PRETTY_NAME=).+\" | tr -d \"\\\"\" ")
    var cpuname = execProcess("lscpu | grep \"Model name\" | tr -s \" \" | awk '{for(i=3;i<=NF;++i)printf $i\"\"FS ; print \"\"}'")
    var architecture = execProcess("lscpu | grep Arch | tr -s \" \" | awk '{print $2}'")

    # Display stuff
    tb.setForegroundColor(fgBlack, true)
    tb.drawRect(0, 0, 70, 14)
    tb.write(2, 1, fgWhite, "nimstatus by", fgYellow, " EataPanini")
    tb.write(2, 2, "Press ", fgYellow, "ESC", fgWhite,
                " or ", fgYellow, "Q", fgWhite, " to quit")
    tb.write(2, 4, fgGreen, "--Stats--")  
    tb.write(2, 5, fgYellow, "Shell ", fgWhite, shell,)
    tb.write(2, 6, fgYellow, "Username ", fgWhite, username,)
    tb.write(2, 7, fgYellow, "Hostname ", fgWhite, hostname,)
    tb.write(2, 8, fgYellow, "Processor ", fgWhite, cpuname,)
    tb.write(2, 9, fgYellow, "Inst-Set ", fgWhite, architecture,)
    tb.write(2, 11, fgGreen, "--Usage--")
    tb.write(2, 12, fgYellow, "Memory ", fgWhite, usedmem,)
    tb.write(2, 13, fgYellow, "CPUsage ", fgWhite, cpusage,)

    #i dont know what this does
    var key = getKey()
    case key
    of Key.None: discard
    of Key.Escape, Key.Q: exitProc()
    else:
            break #what happenes when you press a key, right now it just kills itself
    tb.display()
    sleep(1000)
