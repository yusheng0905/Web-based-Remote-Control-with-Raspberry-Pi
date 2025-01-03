#!/bin/bash

VISITOR_COUNT_FILE="/usr/lib/cgi-bin/visitor_count.txt"

if [ ! -f "$VISITOR_COUNT_FILE" ]; then
    echo "0" > "$VISITOR_COUNT_FILE"
fi
echo "Content-type: text/html; charset=utf-8"
echo ""

if [ "$REQUEST_METHOD" = "POST" ]; then
    read -n $CONTENT_LENGTH POST_DATA
    POST_DATA=$(echo "$POST_DATA" | sed 's/%20/ /g' | sed 's/%26/&/g')
fi

usr1="S1054005"
usr2="M1254006"
usr3="M1254012"
pwd="123"
account=""
password=""
ctrl_action=""
ctrlLL=""
ctrlLF=""
ctrlRL=""
ctrlRF=""
visitor_number=""

btn_style="width:100px; height:30px; border:None; border-radius:6px; color:white;"

if [ -n "$POST_DATA" ]; then
    # 使用 sed 解析帳號和密碼
    account=$(echo "$POST_DATA" | grep -o 'account=[^&]*' | sed 's/.*account=\([^&]*\).*/\1/')
    password=$(echo "$POST_DATA" | grep -o 'password=[^&]*' | sed 's/.*password=\([^&]*\).*/\1/')
    ctrl_action=$(echo "$POST_DATA" | grep -o 'ctrl=[^&]*' | sed 's/.*ctrl=\([^&]*\).*/\1/')
    ctrlLL=$(echo "$POST_DATA" | grep -o 'ctrlLL=[^&]*' | sed 's/.*ctrlLL=\([^&]*\).*/\1/')
    ctrlLF=$(echo "$POST_DATA" | grep -o 'ctrlLF=[^&]*' | sed 's/.*ctrlLF=\([^&]*\).*/\1/')
    ctrlRL=$(echo "$POST_DATA" | grep -o 'ctrlRL=[^&]*' | sed 's/.*ctrlRL=\([^&]*\).*/\1/')
    ctrlRF=$(echo "$POST_DATA" | grep -o 'ctrlRF=[^&]*' | sed 's/.*ctrlRF=\([^&]*\).*/\1/')
fi

echo "<html lang='zh-Hant-TW'><head><title>Remote Controller</title>"
echo "<meta charset='utf-8'>"
echo "<link rel='icon' href='https://cdn-icons-png.flaticon.com/512/5728/5728506.png'>"
echo "<style>"
echo "body {zoom:1.2; background-color:#ffd; text-align:center;}"
echo "header {background-color:#cef;}"
echo "</style></head>"

if [ -n "$account" ] && [ -n "$password" ]; then
    if [[ ("$account" = "$usr1" || "$account" = "$usr2" || "$account" = "$usr3") && "$password" = "$pwd" ]]; then
        if [ "$ctrl_action" = "" ] && [ "$ctrlLL" = "" ] && [ "$ctrlLF" = "" ] && [ "$ctrlRL" = "" ] && [ "$ctrlRF" = "" ]; then
            visitor_number=$(($(cat "$VISITOR_COUNT_FILE") + 1))
            echo "$visitor_number" > "$VISITOR_COUNT_FILE"
        else
            visitor_number=$(($(cat "$VISITOR_COUNT_FILE")))
            echo "$visitor_number" > "$VISITOR_COUNT_FILE"
        fi
        echo "<body><header><h1>Remote Controller</h1><form method='POST' action='final.sh'>"
        echo "<button type='submit' style='$btn_style background-color:#06c; position:absolute; right:1em; top:1em;' name='account' value=''>登出</button>"
        echo "</form></header><section>"
        echo "<form method='POST' action='final.sh'>"
        echo "<pre>   ||   / |  / /                                                                    "
        echo "   ||  /  | / /      ___       //      ___        ___        _   __        ___      "
        echo "   || / /||/ /     //___) )   //     //   ) )   //   ) )   // ) )  ) )   //___) )   "
        echo "   ||/ / |  /     //         //     //         //   / /   // / /  / /   //          "
        echo "   |  /  | /     ((____     //     ((____     ((___/ /   // / /  / /   ((____       </pre>"
        echo "<p>歡迎 $account<input type='hidden' name='account' value='$account'></p>"
        echo "<p>您的密碼是 : $password<input type='hidden' name='password' value='$password'></p>"
        echo "<p>網站瀏覽人數 : <strong>$visitor_number</strong></p>"

        echo "<button style='$btn_style background-color:#393;' type='submit' name='ctrl' value='On'>On</button>"
        echo "<button style='$btn_style background-color:#933;' type='submit' name='ctrl' value='Off'>Off</button>"
        echo "<p></p>"
        echo "<div style='display:inline-flex; height:160px; margin-top:50px;'>"
        echo "<div style='background-color:#e9e; padding:10px;'>"
        echo "<p>Left Room<br><br><button style='$btn_style background-color:#393;' type='submit' name='ctrlLL' value='On'>Left LED On</button>"
        echo "<button style='$btn_style background-color:#393; margin-left:50px;' type='submit' name='ctrlLF' value='On'>Left Fan On</button></p>"
        echo "<p><button style='$btn_style background-color:#933;' type='submit' name='ctrlLL' value='Off'>Left LED Off</button>"
        echo "<button style='$btn_style background-color:#933; margin-left:50px;' type='submit' name='ctrlLF' value='Off'>Left Fan Off</button></p>"
        echo "</div>"

        echo "<div style='background-color:#9e9; padding:10px;'>"
        echo "<p>Right Room<br><br><button style='$btn_style background-color:#393;' type='submit' name='ctrlRL' value='On'>Right LED On</button>"
        echo "<button style='$btn_style background-color:#393; margin-left:50px;' type='submit' name='ctrlRF' value='On'>Right Fan On</button></p>"
        echo "<p><button style='$btn_style background-color:#933;' type='submit' name='ctrlRL' value='Off'>Right LED Off</button>"
        echo "<button style='$btn_style background-color:#933; margin-left:50px;' type='submit' name='ctrlRF' value='Off'>Right Fan Off</button></p>"
        echo "</div>"
        echo "</div>"
 	echo "<div>"

        if [ "$ctrl_action" = "On" ]; then
            echo "<p><span style='background-color:#55f;'>LED 已開啟！</span></p>"
            nohup python3 /usr/lib/cgi-bin/ledOn.py >/dev/null 2>&1 &
        elif [ "$ctrl_action" = "Off" ]; then
            echo "<p><span style='background-color:#f55;'>LED 已關閉！</span></p>"
            nohup python3 /usr/lib/cgi-bin/ledOff.py >/dev/null 2>&1 &
        fi

        if [ "$ctrlLL" = "On" ]; then
            echo "<p><span style='background-color:#e9e;'>- Left LED is on -</p>"
	    gpio -g write 18 1
        elif [ "$ctrlLL" = "Off" ]; then
            echo "<p><span style='background-color:#e9e;'>- Left LED is off -</p>"
	    gpio -g write 18 0
	fi

        if [ "$ctrlLF" = "On" ]; then
            echo "<p><span style='background-color:#e9e;'>- Left Fan is on -</p>"
	    gpio -g write 17 1
        elif [ "$ctrlLF" = "Off" ]; then
            echo "<p><span style='background-color:#e9e;'>- Left Fan is off -</p>"
	    gpio -g write 17 0
        fi
        if [ "$ctrlRL" = "On" ]; then
            echo "<p><span style='background-color:#9e9;'>- Right LED is on -</p>"
	    gpio -g write 22 1
        elif [ "$ctrlRL" = "Off" ]; then
            echo "<p><span style='background-color:#9e9;'>- Right LED is off -</p>"
	    gpio -g write 22 0
        fi
        if [ "$ctrlRF" = "On" ]; then
            echo "<p><span style='background-color:#9e9;'>- Right Fan is on -</p>"
	    gpio -g write 27 1
        elif [ "$ctrlRF" = "Off" ]; then
            echo "<p><span style='background-color:#9e9;'>- Right Fan is off -</p>"
	    gpio -g write 27 0
        fi

    	echo "</div>"

        echo "</form>"

    else
    echo "<body><header><h1>Remote Controller</h1></header><section>"
    echo "<form method='POST' action='final.sh'>"
    echo "<p><span style='background-color:#f55;'>帳號或密碼錯誤!</p>"
    echo "<p>帳號: <input type='text' name='account' required /></p>"
    echo "<p>密碼: <input type='password' name='password' required /></p>"
    echo "<button type='submit' style='$btn_style background-color:#06c;'>登入</button>"
    echo "</form>"
    fi
else
    # 顯示登入頁面
    echo "<body><header><h1>Remote Controller</h1></header><section>"
    echo "<form method='POST' action='final.sh'>"
    echo "<p>帳號: <input type='text' name='account' required /></p>"
    echo "<p>密碼: <input type='password' name='password' required /></p>"
    echo "<button type='submit' style='$btn_style background-color:#06c;'>登入</button>"
    echo "</form>"
fi

echo "</section></body></html>"
