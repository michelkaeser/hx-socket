package hxsocket;

import haxe.io.Bytes;

/**
 *
 */
interface IDgramSocket
{
    /**
     * Connects to the IDgramSocket located at 'path'.
     *
     * @param String path the location of the socket to connect to
     */
    public function connect(path:String):Void;

    /**
     * Reads 'nbytes' from the socket.
     *
     * @param Int nbytes the number of bytes to read
     * @param Int flags  control flags
     *
     * @return { bytes:haxe.io.Bytes, from:Null<String> }
     */
    public function read(nbytes:Int, flags:Int = 0):{ bytes:Bytes, from:Null<String> };

    /**
     * Writes the input bytes to the socket located at 'path'.
     *
     * @param Null<haxe.io.Bytes> bytes the Bytes to send
     * @param Int                 flags control flags
     * @param Null<String>        path  the location of the socket to which we will write
     */
    public function write(bytes:Null<Bytes>, flags:Int = 0, path:Null<String> = null):Int;
}
