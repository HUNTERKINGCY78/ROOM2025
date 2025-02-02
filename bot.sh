#!/bin/bash

PORT=8080
UPLOAD_FOLDER="uploads"
LOGIN_USER="hozoo"
LOGIN_PASS="123456"

# Pastikan folder uploads ada
mkdir -p $UPLOAD_FOLDER

# Fungsi untuk mengirim header HTTP
send_header() {
    echo -ne "HTTP/1.1 $1\r\nContent-Type: $2\r\n\r\n"
}

# Fungsi untuk menampilkan halaman login
login_page() {
    send_header "200 OK" "text/html"
    cat <<EOF
<!DOCTYPE html>
<html>
<head><title>Login</title></head>
<body>
    <h2>Login</h2>
    <form method="POST" action="/login">
        <label>Username:</label><br>
        <input type="text" name="username" required><br><br>
        <label>Password:</label><br>
        <input type="password" name="password" required><br><br>
        <button type="submit">Login</button>
    </form>
</body>
</html>
EOF
}

# Fungsi untuk menampilkan halaman chat
chat_page() {
    send_header "200 OK" "text/html"
    cat <<EOF
<!DOCTYPE html>
<html>
<head><title>Chat Room</title></head>
<body>
    <h2>Welcome to the Chat Room</h2>
    <form method="POST" action="/send">
        <textarea name="message" placeholder="Tulis pesan di sini..." required></textarea><br>
        <button type="submit">Send</button>
    </form>
    <h3>Messages:</h3>
    <ul>
        <!-- Messages will appear here -->
    </ul>
    <a href="/logout">Logout</a>
</body>
</html>
EOF
}

# Fungsi untuk menangani login
handle_login() {
    read -r method path version
    read -r username password

    if [[ "$username" == "$LOGIN_USER" && "$password" == "$LOGIN_PASS" ]]; then
        echo "HTTP/1.1 200 OK"
        echo "Content-Type: text/html"
        echo -e "\r\n"
        echo "<h2>Login Successful</h2>"
        echo "<a href='/chat'>Go to Chat Room</a>"
    else
        send_header "401 Unauthorized" "text/html"
        echo -e "\r\n"
        echo "<h2>Login Failed</h2>"
        echo "<a href='/'>Go Back</a>"
    fi
}

# Fungsi utama untuk menangani permintaan
handle_request() {
    read -r method path version
    case "$path" in
        "/")
            login_page
            ;;
        "/login")
            if [ "$method" == "POST" ]; then
                handle_login
            else
                login_page
            fi
            ;;
        "/chat")
            chat_page
            ;;
        "/logout")
            send_header "200 OK" "text/html"
            echo -e "\r\n"
            echo "<h2>You have been logged out.</h2>"
            echo "<a href='/'>Go Back to Login</a>"
            ;;
        *)
            send_header "404 Not Found" "text/html"
            echo -e "\r\n"
            echo "<h2>Page Not Found</h2>"
            ;;
    esac
}

# Mulai server dan menunggu permintaan di port 8080
while true; do
    { 
        echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n"; 
        cat; 
    } | nc -l -p $PORT -q 1 | while read -r request; do
        handle_request
    done
done
