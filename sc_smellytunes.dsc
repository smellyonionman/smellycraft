###########################################
# Made by Smellyonionman for Smellycraft. #
#          onion@smellycraft.com          #
#    Tested on Denizen-1.1.2-b4566-DEV    #
#              Version 1.3.2              #
#-----------------------------------------#
#     Updates and notes are found at:     #
#  https://smellycraft.com/d/smellytunes  #
#-----------------------------------------#
#    You may use, modify or share this    #
#    script, provided you don't remove    #
#    or alter lines 1-13 of this file.    #
###########################################
sc_tu_init:
    type: task
    debug: false
    script:
    - define namespace:sc_tu
    - define admin:<yaml[sc_tu].read[permissions.admin]||<script[sc_tu_defaults].yaml_key[permissions.admin]||smellytunes.admin>>
    - define targets:<server.list_online_players.filter[has_permission[<[admin]>]].include[<server.list_online_ops>].deduplicate||<player>>
    - define filename:<script[sc_tu_data].yaml_key[filename]>
    - if <server.has_file[../Smellycraft/<[filename]>]>:
      - if <yaml.list.contains[sc_tu]||null>:
        - ~yaml unload id:sc_tu
      - ~yaml load:../Smellycraft/<[filename]> id:sc_tu
    - else:
      - ~yaml create id:sc_tu
      - ~yaml loadtext:<script[sc_tu_defaults].to_json> id:sc_tu
    - if <server.object_is_valid[<script[sc_common_init]>].not>:
        - define msg:'<yaml[sc_tu].read[messages.missing_common]||<script[sc_tu_defaults].yaml_key[messages.missing_common]||&cError>>'
        - narrate <[msg].unescaped.parse_color> targets:<[targets]>
        - stop
    - foreach <yaml[sc_sb].list_keys[scripts]||<script[sc_sb_defaults].list_keys[scripts]||<list[]>>> as:task:
      - if <server.object_is_valid[<script[<yaml[sc_sb].read[scripts.<[task]>]||<script[sc_sb_defaults].yaml_key[scripts.<[task]>]>>]>].not>:
        - define placeholder:<yaml[sc_sb].read[messages.missing_script]||<script[sc_sb_defaults].yaml_key[messages.missing_script]||&cError>>
        - narrate '<[placeholder].replace[[script]].with[<[task]>].separated_by[&sp].unescaped.parse_color>' targets:<[targets]>
        - stop
    - ~yaml savefile:../Smellycraft/<[filename]> id:sc_tu
    - if <server.has_file[../Smellycraft/data/jukeboxes.yml]>:
      - ~yaml load:../Smellycraft/data/jukeboxes.yml id:sc_tu_jb
      - foreach <yaml[sc_tu_jb].list_keys[]> as:jukebox:
        - yaml set <[jukebox]>.state:finished id:sc_tu_jb
    - else:
      - ~yaml create id:sc_tu_jb
    - define feedback:<yaml[sc_tu].read[messages.reload]||<script[sc_tu_defaults].yaml_key[messages.reload]||&cError>>
    - inject <script[<yaml[sc_tu].read[scripts.narrator]||<script[sc_tu_defaults].yaml_key[scripts.narrator]>>]>
sc_tu_cmd:
    type: command
    debug: false
    name: smellytunes
    description: <yaml[sc_tu].read[messages.description]||Interfaces with the Smellytunes plugin.>
    usage: /smellytunes (reload|enable|disable|update|redstone|range|max|credits)
    script:
    - define namespace:sc_tu
    - if <context.args.size.is[MORE].than[0]||false>:
      - define admin:<yaml[sc_tu].read[permissions.admin]||<script[sc_tu_defauls].yaml_key[permissions.admin]||smellytunes.admin>>
      - if <context.args.get[1].to_lowercase.matches[(save|update|reload)]||false>:
        - if <player.has_permission[<[admin]>]||false> || <player.is_op||false> || <context.server>:
          - define arg:<context.args.get[1]>
          - inject <script[sc_common_datacmd]>
      - else if <context.args.get[1].to_lowercase.matches[credits]||false>:
        - define feedback:&9made&spby&spyour&spfriend&sp&6smellyonionman&9!&nl&9Go&spto&sp&ahttps&co//smellycraft.com/smellytunes&sp&9for&spinfo.
      - else if <context.args.get[1].to_lowercase.matches[disable]||false>:
        - if <player.has_permission[<[admin]>]||false> || <player.is_op||false> || <context.server>:
          - if <yaml[sc_tu].read[settings.enabled].not||false>:
            - stop
          - ~yaml set settings.enabled:false
          - define feedback:<yaml[sc_tu].read[messages.disabled]||<script[sc_tu_defaults].yaml_key[messages.disabled]||&cError>>
        - else:
          - define feedback:<yaml[sc_common].read[messages.permission]||<script[sc_common_defaults].yaml_key[messages.permission]||&cError>>
      - else if <context.args.get[1].to_lowercase.matches[enable]||false>:
        - if <player.has_permission[<[admin]>]||false> || <player.is_op||false> || <context.server>:
          - if <yaml[sc_tu].read[settings.enabled]||false>:
            - stop
          - yaml set settings.enabled:true
          - define feedback:<yaml[sc_tu].read[messages.enabled]||<script[sc_tu_defaults].yaml_key[messages.enabled]||&cError>>
        - else:
          - define feedback:<yaml[sc_common].read[messages.permission]||<script[sc_common_defaults].yaml_key[messages.permission]||&cError>>
    - if <[feedback].exists>:
      - inject <script[<yaml[sc_tu].read[scripts.narrator]||<script[sc_tu_defaults].yaml_key[scripts.narrator]||sc_common_feedback>>]>
sc_tu_listener:
    type: world
    debug: true
    events:
        on reload scripts:
        - if <server.has_file[../Smellycraft/<script[sc_tu_data].yaml_key[filename]||smellytunes.yml>].not||false>:
          - inject <script[sc_tu_init]>
        on server start priority:1:
        - inject <script[sc_tu_init]>
        on shutdown:
        - define namespace:sc_tu
        - inject <script[sc_common_save]>
        - yaml savefile:../Smellycraft/data/jukeboxes.yml id:sc_tu_jb
        - yaml unload id:sc_tu
        - yaml unload id:sc_tu_jb
        on delta time hourly:
        - define namespace:sc_tu
        - define silent:true
        - inject <script[sc_common_save]>
        - if <yaml[sc_tu].read[settings.update].to_lowercase.matches[true|enabled]||false>:
          - inject <script[<yaml[sc_tu].read[scripts.update]||<script[sc_tu_defaults].yaml_key[scripts.update]||sc_common_update>>]>
        on player right clicks jukebox:
        - define namespace:sc_tu
        - inject <script[sc_tu_eject]>
        - if <context.item.has_nbt[smellytunes]||false>:
          - if <yaml[sc_tu].read[settings.enabled].not||<script[sc_tu_defaults].yaml_key[settings.enabled].not||false>>:
            - determine fulfilled
          - determine passively cancelled
          - define use:<yaml[sc_tu].read[permissions.use]||<script[sc_tu_defaults].yaml_key[permissions.use]||smellytunes.use>>
          - if <player.has_permission[<[use]>]> || <player.is_op>:
            - define max:<yaml[sc_tu].read[settings.max]||3>
            - foreach <yaml[sc_tu_jb].list_keys[]>:
              - if <yaml[sc_tu_jb].read[<[value]>.state].matches[playing]>:
                - define playing:++
            - define bypass:<yaml[sc_tu].read[permissions.bypass]||<script[sc_tu_defaults].yaml_key[permissions.bypass]||smellytunes.bypass>>
            - if <[playing].is[LESS].than[<[max]>]||true> || <player.has_permission[<[bypass]>]> || <player.is_op>:
              - define redstone:<yaml[sc_tu].read[settings.redstone]||<script[sc_tu_defaults].yaml_key[settings.redstone]||false>>
              - if <[redstone].not.or[<context.location.power.is[MORE].than[0]>]>:
                - if <player.gamemode.matches[SURVIVAL]>:
                  - take <context.item>
                - yaml set <context.location.simple>.track:<context.item.nbt[smellytunes]> id:sc_tu_jb
                - yaml set <context.location.simple>.scriptname:<context.item.scriptname> id:sc_tu_jb
                - yaml set <context.location.simple>.queue:<queue.id> id:sc_tu_jb
                - yaml set <context.location.simple>.state:playing id:sc_tu_jb
                - yaml set sc_tu.playcount.<context.item.scriptname>:++ id:sc_<player.uuid>
                - ~yaml savefile:../Smellycraft/data/jukeboxes.yml id:sc_tu_jb
                - define range:<yaml[sc_tu].read[settings.range]||<script[sc_tu_defaults].yaml_key[settings.range]||5>>
                - define volume:<tern[<[redstone]>].pass[<context.location.power.min[<[range]>]>].fail[<[range]>]>
                - define feedback:<yaml[sc_tu].read[messages.playing]||<script[sc_tu_defaults].yaml_key[messages.playing]||&cError>><&sp><context.item.display.strip_color||&cUnknown>
                - inject <script[<yaml[sc_tu].read[scripts.narrator]||<script[sc_tu_defaults].yaml_key[scripts.narrator]||sc_common_feedback>>]>
                - define dir:<yaml[sc_tu].read[settings.dir]||<script[sc_tu_defaults].yaml_key[settings.dir]||smellytunes>>
                - ~midi file:<[dir]>/<context.item.nbt[smellytunes]> <context.location> volume:<[volume]>
                - yaml set <context.location.simple>.state:finished id:sc_tu_jb
                - ~yaml savefile:../Smellycraft/data/jukeboxes.yml id:sc_tu_jb
              - else:
                - define feedback:<yaml[sc_tu].read[messages.nosignal]||<script[sc_tu_defaults].yaml_key[messages.nosignal]||&cError>>
            - else:
              - define feedback:<yaml[sc_tu].read[messages.playcount]||<script[sc_tu_defaults].yaml_key[messages.playcount]||&cError>>
          - else:
            - define feedback:<yaml[sc_common].read[messages.permission]||<script[sc_common_defaults].yaml_key[messages.permission]||&cError>>
        - if <[feedback].exists>:
          - inject <script[<yaml[sc_tu].read[scripts.narrator]||<script[sc_tu_defaults].yaml_key[scripts.narrator]||sc_common_feedback>>]>
        on player breaks jukebox:
        - define namespace:sc_tu
        - modifyblock <context.location> air naturally
        - inject <script[sc_tu_eject]>
sc_tu_eject:
    type: task
    debug: true
    script:
    - foreach <yaml[sc_tu_jb].list_keys[]> as:jukebox:
      - if <[jukebox].matches[<context.location.simple>]>:
        - determine passively cancelled
        - if <yaml[sc_tu_jb].read[<[jukebox]>.state].matches[playing|finished]>:
          - if <yaml[sc_tu_jb].read[<[jukebox]>.state].matches[playing]>:
            - midi cancel <context.location>
            - define queue:<yaml[sc_tu_jb].read[<[jukebox]>.queue]||null>
            - if <queue.exists[<[queue]>]>:
              - queue <queue[<[queue]>]> stop
        - drop <item[<yaml[sc_tu_jb].read[<[jukebox]>.scriptname]>]> <context.location.relative[0,1,0]>
        - yaml set <[jukebox]>:! id:sc_tu_jb
        - ~yaml savefile:../Smellycraft/data/jukeboxes.yml id:sc_tu_jb
        - stop
sc_tu_data:
    type: yaml data
    version: 1.3.2
    filename: smellytunes.yml
    scripts:
      reload: sc_tu_init
      save: sc_common_save
      update: sc_common_update
sc_tu_defaults:
  type: yaml data
  poorly_disguised_comments:
    if_you_delete_jukeboxes_dot_yml: 'All of your players jukeboxes will be irreversibly emptied.'
    download_common_files_at: 'https://smellycraft.com/denizen/common'
    coming_soon: 'admin gui, redstone controls, vinyl press, surround sound'
    warning: 'this plugin was meant for high performance servers. Set "max" accordingly.'
  settings:
    max: 3
    redstone: false
    range: 5
    enabled: true
    dir: smellytunes
    update: true
  permissions:
    use: smellytunes.use
    bypass: smellytunes.bypass
    admin: smellytunes.admin
  scripts:
    narrator: sc_common_feedback
    GUI: sc_common_marquee
  messages:
    prefix: '&9[&aSmelly&2Tunes&9]'
    description: 'Interfaces with the Smellytunes plugin.'
    reload: '&9Plugin has been successfully reloaded.'
    missing_common: '&This plugin uses code contained in sc_common.yml.  Visit https://smellycraft.com/d/common for the most recent version.'
    missing_script: '&9 Script &a[script] &9was not detected. &c Installation not complete. &9An alternative is available in the Common Files.'
    wait: '&9Please wait...'
    playing: '&9Now playing:'
    playcount: '&cToo many songs playing.'
    nosignal: '&cRedstone signal required.'
    enabled: '&9Plugin has been &aenabled&9.'
    disabled: '&9Plugin has been &cdisabled&9.'
    titlecolor: &a
    lorecolor: &9
