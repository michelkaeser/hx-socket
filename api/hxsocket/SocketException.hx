package hxsocket;

import haxe.PosInfos;
import hxstd.Exception;

/**
 * Exceptions to be thrown when Exceptions from the C FFI need to be wrapped
 * or for any other kind of errors related to libsocket.
 */
class SocketException extends Exception
{
    /**
     * @{inherit}
     */
    public function new(msg:Dynamic = "Uncaught Socket exception", ?info:PosInfos):Void
    {
        super(msg, info);
    }
}
