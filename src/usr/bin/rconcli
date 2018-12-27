#!/usr/bin/python3

import valve.rcon
import os
import sys
from argparse import ArgumentParser


class Rconcli:
    def __init__(self, host='localhost', port=int(os.getenv("CONANEXILES_Game_RconPlugin_RconPort",25575)), pwd=os.getenv("CONANEXILES_Game_RconPlugin_RconPassword")):
        self._host = host
        self._port = port
        self._pwd = pwd

    @property
    def host(self):
        return self._host

    @host.setter
    def host(self, value):
        self._host = value

    @property
    def port(self):
        return self._port

    @port.setter
    def port(self, value):
        self._port = value

    @property
    def pwd(self):
        return self._pwd

    @pwd.setter
    def pwd(self, value):
        self._pwed = value

    def _execute(self, cmd):
        with valve.rcon.RCON((self._host, self._port), self._pwd) as rcon:
            response = rcon.execute(cmd)
            print(response.text)


class Broadcast(Rconcli):
    def __init__(self):
        super().__init__()
        self._list_msgs = ['shutdown', 'update']

    @property
    def list_msgs(self):
        return self._list_msgs

    def _send(self, msg):
        _cmd = 'broadcast'
        self._execute("{} {}".format(_cmd, msg))

    def shutdown(self, mins=15):
        msg = "Server is shutting down in {} minutes.".format(mins)
        self._send(msg)

    def update(self, ver):
        msg = "A new game version is available: {}".format(ver)
        self._send(msg)


def main():
    broadcast= Broadcast()

    parent_parser = ArgumentParser()
    subparsers = parent_parser.add_subparsers(title='actions',
                                              dest='command',
                                              )

    # ADD PARSER
    parser_broadcast = subparsers.add_parser("broadcast",
                                             help="Send a broadcast message",
    )

    parser_broadcast.add_argument("--type",
                                  help='set broadcast type: shutdown, update',
                                  dest="broadcast_type",
                                  choices=(broadcast.list_msgs)
    )

    parser_broadcast.add_argument("--value",
                                  dest="broadcast_value",
                                  help="set broadcast value: shutdown timer in minutes, update version")

    args = parent_parser.parse_args()

    if args.command == 'broadcast':
        if args.broadcast_type == 'shutdown':
            try:
                broadcast.shutdown(args.broadcast_value)
            except Exception as e:
                print(e)
                sys.exit(1)
        if args.broadcast_type == 'update':
            try:
                broadcast.update(args.broadcast_value)
            except Exception as e:
                print(e)
                sys.exit(1)

    sys.exit(0)


if __name__ == "__main__":
    main()
