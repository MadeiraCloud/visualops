#!/bin/bash

#*****************************
#* created date: 2012/12/12
#* Filename:   dep_tool.sh
#* description:  
#* Creater: Jimmy Xu
# *************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# *************************
 
#########################################################################
# Constant Declaration
#########################################################################
#ansi color
B_TAG="\033"
H="[1"
H0="[0"
H1="[1"
E_TAG="\033[0m"
gray="2"
red="31"
green="32"
yellow="33"
blue="34"
purple="35"
cyan="36"
white="37"
black="40"

B="${B_TAG}${H};${white};${black}m"
E="${E_TAG}"

Ht="[7"
Bt="${B_TAG}${Ht};${white};${black}m"
Et="${E_TAG}"

H7="[0"             
B7="${B_TAG}${H};${green};${black}m"
E7="${E_TAG}"

THIN_LINE="${B_TAG}${H};${white};${black}m \t ---  \t-------------------------------\t---------------------------------------${E_TAG}"             
THICK_LINE="${B_TAG}${H};${white};${black}m \t ===  \t===============================\t=======================================${E_TAG}"


BASE_DIR=`cd "$(dirname "$0")"; pwd`
LOG_FILE="dev-tool.log"
echo ${BASE_DIR}
LOG_FILE=${BASE_DIR}/${LOG_FILE}
touch ${LOG_FILE}


#########################################################################
# Function Declaration
#########################################################################
#output log to ${LOG_FILE}
function log_message(){
    lvl=${1:-u}
    msg=$2

    case $lvl in
        i) level="INFO:    "
        ;;
        w) level="WARNING: "
        ;;
        e) level="ERROR:   "
        ;;
        *) level="UNKNOW:  "
        ;;
    esac

    if [[ -n "$LOG_FILE" ]] && [[ -w $LOG_FILE ]]; then
        echo "$(date +%Y/%m/%d\ %H:%M:%S) :$level$msg" >> $LOG_FILE
    	
    else
        echo "ERROR:   no log file specified or it is not writable: $LOG_FILE"
        exit 1
    fi
}



#line move for decorating
function lineMove() {
    clear
    echo
}


function pause() {
    read -n 1 -p "Press any key to continue..."
}


#show menu, read user input   
function create_menu() {

    TITLE=$1

#Menu title       
    echo -e "      ********************* ${B_TAG}${H};${yellow};${black}m ${TITLE} ${E_TAG} *********************"
    echo                                                                                
    echo -e "      ${Bt}   No.   \t`printf %-13sName%-13s` \t `printf %-13sDescription%-13s` ${Et}"

    unset KEY_ARY
    KEY_ARY=( "e=e" )
##Create menuitem ##
    for (( i = 1 ; i <= ${#M_NO[@]} ; i++ ))
    do
        
        NO=${M_NO[$i]}
        NAME=${M_NAME[$i]}
        ITEM=${M_ITEM[$i]}
        DESC=${M_DESC[$i]}
        T=${M_TYPE[$i]}
        SPLIT=${M_SPLIT[$i]}

	    KEY_ARY[$i]=$i

        #add split line
        case "${SPLIT}" in
        1)echo
        	;;
        2)echo -e "      "${THIN_LINE}
        	;;
        3)echo -e "      "${THICK_LINE}
        	;;	
        *)	
        esac
        	
        #show menuitem
        if [ $T == "exit" ] 
        then
    	echo -e "      ${B_TAG}${H};${white};${black}m　　e  ${ITEM}\t${DESC}${E_TAG}"
        else 
    	echo -e "      ${B_TAG}${H1};${white};${black}m    ${NO}\t`printf %-30s "${ITEM}"`\t${DESC}${E_TAG}"
        fi

    done

    echo -e "      "${THICK_LINE}
#            echo -e "      ${B_TAG}${H};${green};${black}mGreen:Software\t\c"
#            echo -e "      ${B_TAG}${H};${white};${black}mWhite:SourceCode\t\c"
#            echo -e "      ${B_TAG}${H1};${cyan};${black}mBlue:ConfigFile${E_TAG}"
    echo 

 			

#Read and execute the user's selection 								

    echo -e "     ${B_TAG}${H};${yellow};${black}m Choice(Input No.):${E_TAG} \c"
    read -n2 CHOICE

    #check input valid
    for key in ${KEY_ARY[@]}
    do
        case ${CHOICE} in
    	  1) break;;
          2) break;;
          3) break;;
          4) break;;
          5) break;;
          6) break;;
          7) break;;
          8) break;;
          9) break;;
    	  e) 
    	     #valid
    	     break;;
    	  *) 
    	     CHOICE="" 
    	     break;;
    	esac
    done;
   
    ORIAL_CHOICE=${CHOICE}

    echo "     You select: "$CHOICE
    
    if [ "$CHOICE" = "e" ]
    then
    #Escape[e]
        CHOICE_NAME="$CHOICE"
    else
    #No->Name
        CHOICE_NAME="${M_NAME[${CHOICE}]}"					
        CHOICE_NAME=${EDIT}${CHOICE_NAME}
    fi


}


#submenu 
function fn_deploy_api() {

    cd ${BASE_DIR}/backend
    lineMove

    TITLE=$1
    		

    while true
    do
    trap   " echo '                Dot not interrupt me!' " INT
    trap   " echo '                Dot not interrupt me!' " TERM

    #Clear menu item array
    unset M_NO
    unset M_TYPE
    unset M_NAME
    unset M_ITEM
    unset M_DESC
    unset M_SPLIT
    		
    #config menu item           
    id=1
    M_NO[$id]=$id
    M_TYPE[$id]="shell_script"
    M_NAME[$id]="sh_redis-bootstrap"
    M_ITEM[$id]="Install Redis"
    M_DESC[$id]="in-memory database" 
    M_SPLIT[$id]=1

    id=2
    M_NO[$id]=$id
    M_TYPE[$id]="shell_script"
    M_NAME[$id]="sh_scribe-bootstrap"
    M_ITEM[$id]="Install Scribe"
    M_DESC[$id]="Log system"
    M_SPLIT[$id]=0

    id=3
    M_NO[$id]=$id
    M_TYPE[$id]="shell_script"
    M_NAME[$id]="sh_gearmand-bootstrap"
    M_ITEM[$id]="Install Gearman"
    M_DESC[$id]="Task Manager"
    M_SPLIT[$id]=0

    id=4
    M_NO[$id]=$id
    M_TYPE[$id]="shell_script"
    M_NAME[$id]="sh_karajan-bootstrap"
    M_ITEM[$id]="Install Karajan"
    M_DESC[$id]=""
    M_SPLIT[$id]=0

    id=5
    M_NO[$id]=$id
    M_TYPE[$id]="shell_script"
    M_NAME[$id]="sh_nginx-bootstrap"
    M_ITEM[$id]="Install Nginx"
    M_DESC[$id]="Web Server"
    M_SPLIT[$id]=0 

    id=6
    M_NO[$id]=$id
    M_TYPE[$id]="shell_script"
    M_NAME[$id]="sh_requestworker-bootstrap"
    M_ITEM[$id]="Install RequestWorker"
    M_DESC[$id]="Request backend processer"
    M_SPLIT[$id]=0 

    id=7
    M_NO[$id]=$id
    M_TYPE[$id]="shell_script"
    M_NAME[$id]="sh_appservice-bootstrap"
    M_ITEM[$id]="Install AppService"
    M_DESC[$id]="Main backend"
    M_SPLIT[$id]=0 
    
                                                                             
    ##--------------------------------------------                
    id=8
    M_NO[$id]=$id
    M_TYPE[$id]="exit"
    M_NAME[$id]="return_mainmenu"
    M_ITEM[$id]=""
    M_DESC[$id]="Return to mainmenu" 
    M_SPLIT[$id]=3  				


    create_menu "[Submenu] ${TITLE}"


    #menu handler
    case "${CHOICE_NAME}" in    

        "sh_scribe-bootstrap")
            execute_script scribe-bootstrap.sh
            fn_deploy_api "$1"
            break;;
        "sh_redis-bootstrap")
            execute_script "redis-bootstrap.sh"
            fn_deploy_api "$1"
            break;;
        "sh_gearmand-bootstrap")
            execute_script "gearmand-bootstrap.sh"
            fn_deploy_api "$1"
            break;;
        "sh_karajan-bootstrap")
            execute_script "karajan-bootstrap.sh"
            fn_deploy_api "$1"
            break;;
        "sh_nginx-bootstrap")
            execute_script "nginx-bootstrap.sh"
            fn_deploy_api "$1"
            break;;
        "sh_requestworker-bootstrap")
            log_message i "Install RequestWorker"
            execute_script "requestworker-bootstrap.sh"
            fn_deploy_api "$1"
            break;;
        "sh_appservice-bootstrap")
            log_message i "Install AppService"
            execute_script "appservice-bootstrap.sh"
            fn_deploy_api "$1"
            break;;
        e) lineMove
            mainMe
            break;;                      
        *) echo -e "                ${B_TAG}${H};${red};${black}m Error： $CHOICE is not a valid option; ${E_TAG}"
          sleep 1
          fn_deploy_api "$1"
    esac
    done
    exit 1
}


#submenu 
function fn_deploy_web() {
    TITLE=$1
    		
    lineMove
    while true
    do
    trap   " echo '                Dot not interrupt me!' " INT
    trap   " echo '                Dot not interrupt me!' " TERM

    #Clear menu item array
    unset M_NO
    unset M_TYPE
    unset M_NAME
    unset M_ITEM
    unset M_DESC
    unset M_SPLIT
    		
    #config menu item           
    id=1
    M_NO[$id]=$id
    M_TYPE[$id]="shell_script"            #config_file, shell_script, exe, jar, view_file, return
    M_NAME[$id]="fn_deploy_web_www"
    M_ITEM[$id]="Deploy Madeiracloud Website"
    M_DESC[$id]="Deploy www.madeiracloud.com" 
    M_SPLIT[$id]=1  				

    ##--------------------------------------------
    id=2
    M_NO[$id]=$id
    M_TYPE[$id]="shell_script"
    M_NAME[$id]="fn_deploy_web_pugna"
    M_ITEM[$id]="Deploy Pugna"
    M_DESC[$id]="Deploy ide.madeiracloud.com " 
    M_SPLIT[$id]=2  							

                                                                             
    ##--------------------------------------------                
    id=3
    M_NO[$id]=$id
    M_TYPE[$id]="exit"
    M_NAME[$id]="return_mainmenu"
    M_ITEM[$id]=""
    M_DESC[$id]="Return to mainmenu" 
    M_SPLIT[$id]=3  				


    create_menu "[Submenu] ${TITLE}"

            
    #menu handler
    case "${CHOICE_NAME}" in    
       "fn_deploy_web_www")
                #
                log_message i "Deploy WWW OK"
                fn_deploy_web "$1"
                break;;                   
        "fn_deploy_web_pugna")
                #
                log_message i "Deploy Pugna OK"
                fn_deploy_web "$1"
                break;;        
        e) lineMove
                mainMe
                break;;                      
        *) echo -e "                ${B_TAG}${H};${red};${black}m Error： $CHOICE is not a valid option; ${E_TAG}"
                sleep 1
                fn_deploy_web "$1"
    esac
    done
    exit 1
}



#submenu 
function fn_process_manage() {
    TITLE=$1
            
    lineMove
    while true
    do
    trap   " echo '                Dot not interrupt me!' " INT
    trap   " echo '                Dot not interrupt me!' " TERM

    #Clear menu item array
    unset M_NO
    unset M_TYPE
    unset M_NAME
    unset M_ITEM
    unset M_DESC
    unset M_SPLIT
            
    #config menu item           

    id=1
    M_NO[$id]=$id
    M_TYPE[$id]="shell_script"
    M_NAME[$id]="sh_supervisord_run"
    M_ITEM[$id]="Start process"
    M_DESC[$id]="Run supervisord"
    M_SPLIT[$id]=1

    id=2
    M_NO[$id]=$id
    M_TYPE[$id]="shell_script"
    M_NAME[$id]="sh_supervisorctl_check"
    M_ITEM[$id]="Check process(supervisorctl)"
    M_DESC[$id]="Run 'watch supervisorctl status'"
    M_SPLIT[$id]=0

    id=3
    M_NO[$id]=$id
    M_TYPE[$id]="shell_script"
    M_NAME[$id]="sh_supervisorctl_shutdown"
    M_ITEM[$id]="Shutdown process(supervisorctl)"
    M_DESC[$id]="Run 'supervisorctl shutdown'"
    M_SPLIT[$id]=0  

                   
    id=4
    M_NO[$id]=$id
    M_TYPE[$id]="shell_script"            #config_file, shell_script, exe, jar, view_file, return
    M_NAME[$id]="sh_ps_check"
    M_ITEM[$id]="Check process(ps)"
    M_DESC[$id]="Check process status by ps" 
    M_SPLIT[$id]=1

    id=5
    M_NO[$id]=$id
    M_TYPE[$id]="shell_script"
    M_NAME[$id]="sh_kill_process"
    M_ITEM[$id]="Kill process"
    M_DESC[$id]="Kill all process" 
    M_SPLIT[$id]=0  

    ##--------------------------------------------                
    id=6
    M_NO[$id]=$id
    M_TYPE[$id]="exit"
    M_NAME[$id]="return_mainmenu"
    M_ITEM[$id]=""
    M_DESC[$id]="Return to mainmenu" 
    M_SPLIT[$id]=3                  


    create_menu "[Submenu] ${TITLE}"

            
    #menu handler
    case "${CHOICE_NAME}" in                  
        "sh_supervisorctl_check")
            watch supervisorctl status
            fn_process_manage "$1"
            break;;      
        "sh_supervisord_run")
            supervisord -c /madeira/conf/supervisord.conf
            pause
            fn_process_manage "$1"
            break;;      
        "sh_supervisorctl_shutdown")
            supervisorctl shutdown
            pause
            fn_process_manage "$1"
            break;;            
        "sh_ps_check")
            echo "###############################################"
            echo "#          All process status:"
            echo "###############################################"
            ps -ef | grep -E "AppService|scribed|Karajan|mongod|mysql|redis-server|gearmand|supervisord|zookeeper|RequestWorker|php-fpm|nginx|meteor|node" | grep -v grep | awk '{len=length($0);if (len<=128){print $0;}else{printf "%s...\n", substr($0,1,128); }}'
            pause
            fn_process_manage "$1"
            break;;  
        "sh_kill_process")
            ps -ef | grep -E "AppService|scribed|Karajan|mongod|mysql|redis-server|gearmand|supervisord|zookeeper|RequestWorker|php-fpm|nginx|meteor|node" | grep -v "grep" | awk '{system("kill -9 "$2)}'
            pause
            fn_process_manage "$1"
            break;;                
        e) lineMove
            mainMe "$1"
            break;;                      
        *) echo -e "                ${B_TAG}${H};${red};${black}m Error： $CHOICE is not a valid option; ${E_TAG}"
            sleep 1
            fn_process_manage "$1"
    esac
    done
    exit 1
}



#execute shell script file
function execute_script() {
    
    SCRIPT_FILE=$1
    echo 
    echo -e -n "${B_TAG}${H1};${blue};${black}m      Are you sure to run shell script ${SCRIPT_FILE} ?${E_TAG} (y for continue,other for cancel):"
    read CHOICE
    if [ "$CHOICE" != "y" ]
    then
        echo "================================================"
        echo -e "${B_TAG}${H1};${cyan};${black}m      Cancel run shell script ${SCRIPT_FILE} ${E_TAG}x "
        echo "================================================"
        #mainMe;
        sleep 1
    else
        #execute script file
        echo "Start run shell script file: ${SCRIPT_FILE}"
        ./${SCRIPT_FILE}

        echo "================================================"
        echo "= Run shell script  ${SCRIPT_FILE} finish ="
        echo "================================================"

        pause

    fi
    
}


function check_mongodb() {
    which mongo mongod >/dev/null 2>&1
    if [ $? -eq 0 ];then
        echo ""
        echo ">mongodb had been installed!"
        echo "-----------------------------"
        whereis mongo mongod
        echo "-----------------------------"
        mongo --version
        echo "-----------------------------"
        mongod --version
    else
        echo " >mongodb not installed!"
    fi
}

function check_zookeeper() {
    which /usr/sbin/zookeeper/bin/zkServer.sh >/dev/null 2>&1 
    if [ $? -eq 0 ];then
        echo ""
        echo ">zookeeper had been installed!"
        echo "-----------------------------"
        which /usr/sbin/zookeeper/bin/zkServer.sh
        echo "-----------------------------"
        ls /usr/sbin/zookeeper/zookeeper-*.jar
    else
        echo " >zookeeper not installed!"
    fi
}

function check_supervisor() {
    which supervisorctl supervisord >/dev/null 2>&1 
    if [ $? -eq 0 ];then
        echo ""
        echo ">supervisor had been installed!"
        echo "-----------------------------"
        which supervisorctl supervisord
        echo "-----------------------------"
        echo "supervisord version:"
        supervisord --version
    else
        echo " >supervisor not installed!"
    fi
}

#####################################################################
#Display main menu
function mainMe() {

    cd ${BASE_DIR}
    lineMove

    while true
    do
        trap   " echo '                Dot not interrupt me!' " INT
        trap   " echo '                Dot not interrupt me!' " TERM

        #Empty menu array
        unset M_NO       #No of menuitem
        unset M_TYPE     #menuitem type   (config_file, shell_script, exit, return )
        unset M_NAME     #function name
        unset M_ITEM     #menuitem name(display)
        unset M_DESC     #menuitem description(display)
        unset M_SPLIT	 #splitter type ( 0 no splitter   1 blank line   2 add THIN_LINE   3 add THICK_LINE )

        #Menu config               
        id=1
        M_NO[$id]=$id
        M_TYPE[$id]="shell_script"
        M_NAME[$id]="sh_deploy_mongodb"
        M_ITEM[$id]="Deploy Mongodb     "
        M_DESC[$id]="NoSQL database"
        M_SPLIT[$id]=1

        id=2
        M_NO[$id]=$id
        M_TYPE[$id]="shell_script"
        M_NAME[$id]="sh_deploy_mysql"
        M_ITEM[$id]="Deploy MySQL     "
        M_DESC[$id]="MySQL Server" 
        M_SPLIT[$id]=0

        id=3
        M_NO[$id]=$id
        M_TYPE[$id]="shell_script"
        M_NAME[$id]="sh_deploy_zookeeper"
        M_ITEM[$id]="Deploy Zookeeper     "
        M_DESC[$id]="Distributed locks" 
        M_SPLIT[$id]=0

        id=4
        M_NO[$id]=$id
        M_TYPE[$id]="shell_script"
        M_NAME[$id]="sh_deploy_supervisord"
        M_ITEM[$id]="Deploy Supervisor     "
        M_DESC[$id]="Process control" 
        M_SPLIT[$id]=0 

        id=5
        M_NO[$id]=$id
        M_TYPE[$id]="shell_script"
        M_NAME[$id]="fn_deploy_api"
        M_ITEM[$id]="Deploy Api    "
        M_DESC[$id]="Deploy https://api.madeiracloud.com" 
        M_SPLIT[$id]=1

        id=6
        M_NO[$id]=$id
        M_TYPE[$id]="shell_script"
        M_NAME[$id]="fn_deploy_web"
        M_ITEM[$id]="Deploy Web(demo)     "
        M_DESC[$id]="Deploy http://www.madeiracloud.com" 
        M_SPLIT[$id]=0

        id=7
        M_NO[$id]=$id
        M_TYPE[$id]="shell_script"
        M_NAME[$id]="fn_deploy_dns"
        M_ITEM[$id]="Deploy Dns(demo)     "
        M_DESC[$id]="Customize bind" 
        M_SPLIT[$id]=0

        id=8
        M_NO[$id]=$id
        M_TYPE[$id]="shell_script"
        M_NAME[$id]="fn_process_manage"
        M_ITEM[$id]="Manage process     "
        M_DESC[$id]="Check status, kill, start" 
        M_SPLIT[$id]=1


        id=9
        M_NO[$id]=$id
        M_TYPE[$id]="exit"
        M_NAME[$id]="exit_shell"
        M_ITEM[$id]=""
        M_DESC[$id]="Exit" 
        M_SPLIT[$id]=1

        create_menu "[MainMenu] Madeiracloud deploy tool"


    #menuitem handler
        case "${CHOICE_NAME}" in
            "clear_history") 
                echo -e "${B_TAG}${H1};${red};${black}m Are you sure to clear all history data?${E_TAG} y for continue,other for cancel"
                read CHOICE
                if [ "$CHOICE" != "y" ]
                then
                    mainMe;
                else
                    echo "clearing history data"
                    #rm ../get_bgp_v2/orial/*.* >/dev/null 2>&1
                    echo
                    echo "History data clear finish!"
                    echo -e "${E7}"
                    echo "Press any key to return to the menu..."
                    read -n 1
                    mainMe;
                fi
                break;;
            "sh_deploy_mongodb")
                check_mongodb
                cd backend
                execute_script "mongodb-bootstrap.sh"
                mainMe
                break;;
            "sh_deploy_mysql")
                cd backend
                execute_script "mysql-bootstrap.sh"
                mainMe
                break;;
            "sh_deploy_zookeeper")
                check_zookeeper
                cd backend
                execute_script "zookeeper-bootstrap.sh"
                mainMe
                break;;
            "sh_deploy_supervisord")
                check_supervisor
                cd supervisord
                execute_script "supervisord-bootstrap.sh"
                mainMe
                break;;
            "fn_deploy_api")
                fn_deploy_api "${ORIAL_CHOICE}.${M_DESC[${ORIAL_CHOICE}]}"
                mainMe
                break;;
            "fn_deploy_web")
                fn_deploy_web "${ORIAL_CHOICE}.${M_DESC[${ORIAL_CHOICE}]}"
                mainMe
                break;;
            "fn_deploy_dns")
                fn_deploy_dns "${ORIAL_CHOICE}.${M_DESC[${ORIAL_CHOICE}]}"
                mainMe
                break;;         
            "fn_process_manage")
                fn_process_manage "${ORIAL_CHOICE}.${M_DESC[${ORIAL_CHOICE}]}"
                mainMe
                break;;     
            e) lineMove
                exit 1;;

            *) echo -e "                ${B_TAG}${H};${red};${black}m error： $CHOICE is not a valid option; ${E_TAG}"
                sleep 1
                mainMe
        esac

    done
    exit 1
}

 
#########################################################################
# Main
#########################################################################
mainMe

