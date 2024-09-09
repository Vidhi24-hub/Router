# Router 1x3

This project implements a Router 1x3, a device that forwards data packets between computer networks based on the packet's destination address. The router operates at Layer 3 (Network Layer) of the OSI model, and drives packets to one of three output channels based on the address field in the packet header. 

# Overview

The Router 1x3 follows a packet-based protocol, handling data packets from multiple networks. It receives network packets from a source LAN byte by byte on the active positive edge of the clock.

The start of a new packet is indicated by asserting **pkt_valid**, and the end is marked by deasserting **pkt_valid**. The router stores incoming packets in a FIFO corresponding to the destination LAN based on the address in the packet header. The router contains three FIFOs for the respective destination LANs. During packet read operations, the destination LANs monitor **vld_out_x** (where x = 0, 1, or 2) and assert **read_enb_x** to read packets via **data_out_x** channels. The router can enter a busy state, indicated by a busy signal sent back to the source LAN. This signal instructs the source LAN to wait before sending the next byte of the packet. The router employs a parity check mechanism to ensure data integrity. If there is a mismatch between the parity byte sent by the source LAN and the parity calculated by the router, an error signal is asserted. This error signal prompts the source LAN to resend the packet. The router can only receive one packet at a time, it can read up to three packets simultaneously, ensuring efficient processing and transmission across multiple networks.



# Key Features

**Sending and Receiving Packet** : The router is capable of handling both packet transmission and reception simultaneously, ensuring smooth data flow between networks.

**Packet Routing** : Packets are routed from the input port to one of the output ports based on the destination network address, ensuring efficient data transmission across networks.

**Parity Checking** : An error detection technique that tests the integrity of digital data transmitted between the server and client. This ensures that data sent by the server network is received by the client network without corruption.

**Reset** : The router has an active-low synchronous reset. Under reset conditions, the router's FIFOs are emptied, and the valid output signals go low, indicating no valid packet is detected on the output data bus.
