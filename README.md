# Router 1x3

This project implements a Router 1x3, a device that forwards data packets between computer networks based on the packet's destination address. The router operates at Layer 3 (Network Layer) of the OSI model, and drives packets to one of three output channels based on the address field in the packet header.

**Key Features**
Sending and Receiving Packet : The router is capable of handling both packet transmission and reception simultaneously, ensuring smooth data flow between networks.
Packet Routing : Packets are routed from the input port to one of the output ports based on the destination network address, ensuring efficient data transmission across networks.
Parity Checking : An error detection technique that tests the integrity of digital data transmitted between the server and client. This ensures that data sent by the server network is received by the client network without corruption.
Reset : The router has an active-low synchronous reset. Under reset conditions, the router's FIFOs are emptied, and the valid output signals go low, indicating no valid packet is detected on the output data bus.
