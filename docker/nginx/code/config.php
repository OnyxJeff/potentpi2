<?php

/**
 * Description of requests
 *
 * @author DarkCloud
 * 
 * Torrent Client can be either qbittorrent or Transmission, no others are supported currently.
 */
$cfg_array = [
    'Title' => 'OnyxNet HQ',
    'units' => 'us',
    'lang' => 'en',
    'refesh_in_seconds' => '300',
    'Show_Torrents' => '',
    'Torrent_Client' => '',
    'Torrent_Server_IP' => '',
    'Torrent_Server_Port' => '',
    'Torrent_username' => '',
    'Torrent_password' => '',
    'show_storage' => '',
    'storage_path' => '',
    'storage_name' => '',
    'enable_reddit' => 'false',
    'enable_grafana' => 'true',
];
return $cfg_array;
