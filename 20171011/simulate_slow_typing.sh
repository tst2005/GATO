#!/usr/bin/expect

# from expect man
# The -h flag forces output to be sent (somewhat) like a human actually
# typing. Human-like delays appear between the characters. (The algorithm
# is based upon a Weibull distribution, with modifications to suit this
# particular application.) This output is controlled by the value of the
# variable "send_human" which takes a five element list.
# The first two elements are average interarrival time of characters in
# seconds.
#  The first is used by default.
#  The second is used at word endings, to simulate the subtle pauses
#    that occasionally occur at such transitions.
# The third parameter is a measure of variability where .1 is quite variable, 1
# is reasonably variable, and 10 is quite invariable. The extremes are
# 0 to infinity.
# The last two parameters are, respectively, a minimum and maximum
# interarrival time. The minimum and maximum are used last and
# "clip" the final time. The ultimate average can be quite different from
# the given average if the minimum and maximum clip enough values.
# As an example, the following command emulates a fast and consistent typist:
#    set send_human {.1 .3 1 .05 2}
#    send -h "I'm hungry.  Let's do lunch."
# while the following might be more suitable after a hangover:
#    set send_human {.4 .4 .2 .5 100}
#    send -h "Goodd party lash night!"
# Note that errors are not simulated, although you can set up error
# correction situations yourself by embedding mistakes and corrections in
# a send argument.

set send_human {.1 .2 1 .05 2}
set prompt {localhost}
set dir /home/jean/src
set cmds {
	{{# I will now list files in a directory} 1}
	{{# The timestamp displayed is the time of last modification}  1}
	{{ls -l} 1 }
	{{# I will now use another option of ls} 1}
	{{ls --time=atime -l} 1 }
	{{# Look closely !} 2 }
	{{# Do you see differences between the timestamps ?} 10 }
	{{# This option --time=atime -> shows the last access timestamp} 1 }
	{{# I will now do a recursive grep in the directory} 1 }
	{{grep -r myregexp .} 1 }
	{{# See how the access timestamps were all modified ?} 1 }
	{{ls --time=atime -l} 1 }
}

proc send_slow_command {cmd} {
  send -h "$cmd\r"
}
proc get_command_result {cmd} {
  stty -echo
  spawn -noecho bash -c "$cmd;printf '\u00a0';echo"
  stty echo
  send "\r\r"
  expect \u00a0
}



cd /home/jean/src
send "localhost$ "
sleep 7
foreach e $cmds {
	lassign $e cmd delay
	send_slow_command $cmd
	get_command_result $cmd
  	send "localhost$ "
	sleep $delay
}
sleep 100
