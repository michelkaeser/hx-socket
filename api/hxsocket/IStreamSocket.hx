package hxsocket;

import haxe.io.Bytes;

/**
 *
 */
interface IStreamSocket
{
    /**
     * Accepts an incoming stream socket connection.
     *
     * @param Int flags the control flags defining how to wait for/accept connections
     *
     * @return hxsocket.IStreamSocket
     */
    public function accept(flags:Int = 0):IStreamSocket

    /**
     * Reads 'nbytes' from the socket.
     *
     * @param Int nbytes the number of bytes to read
     *
     * @return haxe.io.Bytes
     */
    public function read(nbytes:Int):Bytes;

    /**
     * Shuts the sockets 'method' stream down.
     *
     * @param Int method the stream to shutdown
     */
    public function shutdown(method:Int):Void

    /**
     * Writes the input bytes to the socket.
     *
     * @param Null<haxe.io.Bytes> bytes the Bytes to send
     */
    public function write(bytes:Null<Bytes>):Int
}
