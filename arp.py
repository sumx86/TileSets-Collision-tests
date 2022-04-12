from __future__ import print_function
from struct import pack
from scapy.all import *
from scapy.layers.l2 import ARP, Ether
import time
import threading
import socket

ARP_REPLY = 0x02
ADAPTER = "Ethernet"
LOCAL_IP_ADDRESS = get_if_addr(ADAPTER)

SERVER_PORT = 3000
IP_ADDR = "127.0.0.1"
socket_initialized = False
sock = None
packet_count = 1

mutex = threading.Lock()

def init_sock(port, addr):
    global sock
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect(((addr, port)))
    socket_initialized = True

def send_tcp_data(data):
    global sock
    global socket_initialized
    if not socket_initialized:
        init_sock(SERVER_PORT, IP_ADDR)
    sock.send(data.encode())

def send_arp(ip):
    global packet_count
    sendp(Ether(dst='ff:ff:ff:ff:ff') / ARP(pdst=ip), iface=ADAPTER)
    mutex.acquire()
    send_tcp_data("Packet - " + str(packet_count))
    mutex.release()
    packet_count += 1
    time.sleep(0.2)

def receive_arp(packet):
    if packet[ARP].op == ARP_REPLY:
        if "0.0.0.0" in packet.pdst or LOCAL_IP_ADDRESS in packet.pdst:
            src_ip = packet.psrc
            src_hw = packet.hwsrc
            mutex.acquire()
            send_tcp_data(src_ip + "#" + src_hw)
            mutex.release()

def receiver():
    sniff(filter="arp", iface=ADAPTER, prn=receive_arp)

if __name__ == "__main__":
    thread = threading.Thread(target=receiver, args=())
    thread.start()
    time.sleep(2)
    for i in range(1, 256):
        send_arp("192.168.0." + str(i))