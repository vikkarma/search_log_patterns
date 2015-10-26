#!/bin/sh

usage() {
    echo ""
    echo ""
    echo "  ================================= USAGE OPTIONS =================================="
    echo "  `basename $0` " 1>&2
    echo "      [-h |--help <Display help or usage for the script>]" 1>&2
    echo "      [-ho|--hourly <true gives hourly stats (default=false)>]" 1>&2
    echo "      [-d |--daily <true gives daily stats (default=false)>]" 1>&2
    echo "      [-s |--start <startTime example 07/01/2015:00:00:00>]" 1>&2
    echo "      [-e |--end <endTime example 07/03/2015:00:00:00>]" 1>&2
    echo "      [-f |--patternfile <file with all patterns to be searched>]" 1>&2
    echo "      [-ser |--service <hbase/hadoop/zookeeper/etc>]" 1>&2
    echo "      [-host |--hostmatchprefix <specific hostname like blitzhbase01-mnds1-1>]" 1>&2
    echo ""
    echo "  ================================== EXAMPLE ========================================"
    echo "  ./search_log_patterns.sh.sh  -f ../config/hbase_exception_patterns" 
    echo "  ./search_log_patterns.sh.sh  -f ../config/hbase_error_patterns" 
    echo ""
}


countFilePatterns() {
    pattern_ctr_cmd=""
    grep_cmd="test"
    if [ -z ${service+x} ]
    then 
        pattern_files="${pattern_files}""*"
    else
        pattern_files="${pattern_files}${service}""*"
    fi
    if [ -z ${hostmatchprefix+x} ]
    then 
        pattern_files="${pattern_files}"".log*"
    else
        pattern_files="${pattern_files}${hostmatchprefix}"".log*"
    fi

    while read line;do
        if [ ${hourly} = 'true' ]
        then
            pattern_cmd="/${line}/{pattern[\$1 \" ${line}\"]+=1}"
        elif [ ${daily} = 'true' ]
        then
            pattern_cmd="/${line}/{pattern[\$1 \" ${line}\"]+=1}"
        else
            pattern_cmd="/${line}/{pattern[\"${line}\"]+=1}"
        fi
        pattern_ctr_cmd="${pattern_ctr_cmd}${pattern_cmd}"
        grep_cmd="${grep_cmd}|${line}"
    done < $FILE

    end_command="END{for (x in pattern) {print x, pattern[x]}}"
    if [ ${hourly} = 'true' ]
    then 
        echo "Running cat ${HOME_DIR}/logs/hbase* | awk -F: ${pattern_ctr_cmd} ${end_command}"
        pattern_output=`cat ${HOME_DIR}/logs/hbase* | awk -F: "${pattern_ctr_cmd} ${end_command}" | sort`
    elif [ ${daily} = 'true' ]
    then
        echo "Running cat ${HOME_DIR}/logs/hbase* | awk ${pattern_ctr_cmd} ${end_command}"
        pattern_output=`cat ${HOME_DIR}/logs/hbase* | awk "${pattern_ctr_cmd} ${end_command}" | sort`
    else
        echo "Running cat ${HOME_DIR}/logs/hbase* | awk ${pattern_ctr_cmd} ${end_command}"
        pattern_output=`cat ${HOME_DIR}/logs/hbase* | awk "${pattern_ctr_cmd} ${end_command}" | sort`
    fi
    echo "${pattern_output}"

    echo "Running grep xception ${HOME_DIR}/logs/hbase* | egrep -v \"${grep_cmd}\"| wc -l"
    grep_output=`grep xception ${HOME_DIR}/logs/hbase* | egrep -v \"${grep_cmd}\"| wc -l`
    echo "New Exceptions not seen earlier:"
    echo "${grep_output}"
}

# Parse user options
daily='false'
hourly='false'
while [ $# -gt 0 ]
do
key="$1"
case $key in
    -h|--help)
    usage
    exit
    ;;
    -d|--daily)
    daily="$2"
    shift
    ;;
    -ho|--hourly)
    hourly="$2"
    shift
    ;;
    -s|--start)
    start="$2"
    shift
    ;;
    -e|--end)
    end="$2"
    shift
    ;;
    -ser|--service)
    service="$2"
    shift
    ;;
    -host|--hostmatchprefix)
    hostmatchprefix="$2"
    shift
    ;;
    -f|--patternfile)
    FILE="$2"
    shift
    ;;
    *)
    usage   # unknown option
    exit
    ;;
esac
shift # past argument or value 
done
HOME_DIR="/home/vikas/"
countFilePatterns




