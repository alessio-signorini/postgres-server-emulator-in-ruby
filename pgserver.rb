#!/usr/bin/env ruby

require 'socket'
require 'openssl'

server = TCPServer.new 15432

# Establish an SSL context
sslContext = OpenSSL::SSL::SSLContext.new
sslContext.cert = OpenSSL::X509::Certificate.new( File.open( 'cert.pem' ) );
sslContext.key = OpenSSL::PKey::RSA.new( File.open( 'key.pem' ) );

# Create SSL server
sslServer = OpenSSL::SSL::SSLServer.new( server, sslContext );
sslServer.start_immediately = false;

client = sslServer.accept;

puts " - Receiving SSLRequest"
(length,code) = client.sysread(8).unpack('L>L>')
puts "   * LENGTH=#{length}, CODE=#{code}"

puts " + Responding YES to SSL"
puts client.syswrite(['S'].pack('A'))
client.accept

puts " - Receiving StartupMessage"
(length,major,minor) = client.sysread(8).unpack('L>S>S>')
puts "   * LENGTH=#{length}, CODE=#{major}, MINOR=#{minor}"
data = client.sysread(length-8)
puts "   * DATA=#{data}"

puts " + Sending AuthenticationMD5Password"
data = ['R',12,5].pack('AL>L>') + Random.new.bytes(4)
puts client.syswrite(data)

puts " - Receive PasswordMessage"
(type, length) = client.sysread(5).unpack('AL>')
puts "   * TYPE=#{type}, LENGTH=#{length}"
data = client.sysread(length-4)
puts "   * DATA=#{data}"

puts " + Sending AuthenticationOk"
puts client.syswrite(['R', 8, 0].pack('AL>L>'))

puts " + Sending ReadyForQuery"
puts client.syswrite(['Z',5,'I'].pack('AL>A'))

data = client.sysread(100)
puts data.unpack('C*')

sleep(100)

client.close
