sc_tu_init:
    type: task
    debug: true
    script:
    - define namespace:sc_tu
    - define admin:<yaml[sc_tu].read[permissions.admin]||<script[sc_tu_defaults].yaml_key[permissions.admin]||smellytunes.admin>>
    - define targets:<server.list_online_players.filter[has_permission[<[admin]>]].include[<server.list_online_ops>].deduplicate||<player>>
    - if <server.has_file[../Smellycraft/smellytunes.yml]>:
      - ~yaml load:../Smellycraft/smellytunes.yml id:sc_tu
    - else:
      - ~yaml create id:sc_tu
      - ~yaml loadtext:<script[sc_tu_defaults].to_json> id:sc_tu
      - ~yaml savefile:../Smellycraft/smellytunes.yml id:sc_tu
      - yaml set version:1.0 id:sc_tu
    - if <server.has_file[../Smellycraft/data/jukeboxes.yml]>:
      - ~yaml load:../Smellycraft/data/jukeboxes.yml id:sc_tu_jb
      - foreach <yaml[sc_tu_jb].list_keys[jukeboxes]> as:jukebox:
        - yaml set <[jukebox]>.state:finished id:sc_tu_jb
    - else:
      - ~yaml create id:sc_tu_jb
      - ~yaml set jukeboxes:[] id:sc_tu_jb
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
      - if <context.args.get[1].to_lowercase.matches[reload]||false>:
        - if <player.has_permission[<[admin]>]||false> || <player.is_op||false> || <context.server>:
          - inject <script[sc_tu_init]>
          - stop
        - else:
          - define feedback:<yaml[sc_tu].read[messages.permission]||<script[sc_tu_defaults].yaml_key[messages.permission]||&cError>>
      - if <context.args.get[1].to_lowercase.matches[update]||false>:
        - if <player.has_permission[<[admin]>]||false> || <player.is_op||false> || <context.server>:
          - inject <script[<yaml[sc_tu].read[scripts.updater]||<script[sc_tu_defaults].yaml_key[scripts.updater]||sc_common_update>>]>
          - stop
        - else:
          - define feedback:<yaml[sc_tu].read[messages.permission]||<script[sc_tu_defaults].yaml_key[messages.permission]||&cError>>
      - else if <context.args.get[1].to_lowercase.matches[credits]||false>:
        - define feedback:&9made&spby&spyour&spfriend&sp&6smellyonionman&9!&nl&9Go&spto&sp&ahttps&co//smellycraft.com/smellytunes&sp&9for&spinfo.
      - else if <context.args.get[1].to_lowercase.matches[disable]||false>:
        - if <player.has_permission[<[admin]>]||false> || <player.is_op||false> || <context.server>:
          - if <yaml[sc_tu].read[settings.enabled].not||false>:
            - stop
          - ~yaml set settings.enabled:false
          - define feedback:<yaml[sc_tu].read[messages.disabled]||<script[sc_tu_defaults].yaml_key[messages.disabled]||&cError>>
        - else:
          - define feedback:<yaml[sc_tu].read[messages.permission]||<script[sc_tu_defaults].yaml_key[messages.permission]||&cError>>
      - else if <context.args.get[1].to_lowercase.matches[enable]||false>:
        - if <player.has_permission[<[admin]>]||false> || <player.is_op||false> || <context.server>:
          - if <yaml[sc_tu].read[settings.enabled]||false>:
            - stop
          - yaml set settings.enabled:true
          - define feedback:<yaml[sc_tu].read[messages.enabled]||<script[sc_tu_defaults].yaml_key[messages.enabled]||&cError>>
        - else:
          - define feedback:<yaml[sc_tu].read[messages.permission]||<script[sc_tu_defaults].yaml_key[messages.permission]||&cError>>
    - if <[feedback].exists>:
      - inject <script[<yaml[sc_tu].read[scripts.narrator]||<script[sc_tu_defaults].yaml_key[scripts.narrator]||sc_common_feedback>>]>
sc_tu_listener:
    type: world
    debug: true
    events:
        on reload scripts:
        - if <server.has_file[../Smellycraft/smellytunes.yml].not||false>:
          - inject <script[sc_tu_init]>
        on server start priority:1:
        - inject <script[sc_tu_init]>
        on shutdown:
        - yaml savefile:../Smellycraft/smellytunes.yml id:sc_tu
        - yaml savefile:../Smellycraft/data/jukeboxes.yml id:sc_tu_jb
        - yaml unload id:sc_tu
        - yaml unload id:sc_tu_jb
        on delta time hourly:
        - define namespace:sc_tu
        - if <yaml[sc_tu].read[settings.update].to_lowercase.matches[true|enabled]||false>:
          - inject <script[<yaml[sc_tu].read[scripts.updater]||<script[sc_tu_defaults].yaml_key[scripts.updater]||sc_common_updater>>]>
        on player right clicks jukebox:
        - define namespace:sc_tu
        - inject <script[sc_tu_eject]>
        - if <context.item.has_nbt[smellytunes]||false>:
          - if <yaml[sc_tu].read[settings.enabled].not||false>:
            - stop
          - determine passively cancelled
          - define use:<yaml[sc_tu].read[permissions.use]||<script[sc_tu_defaults].yaml_key[permissions.use]||smellytunes.use>>
          - if <player.has_permission[<[use]>]> || <player.is_op>:
            - define max:<yaml[sc_tu].read[settings.max]||3>
            - define playing:<yaml[sc_cache].read[sc_tu.playing]||0>
            - define bypass:<yaml[sc_tu].read[permissions.bypass]||<script[sc_tu_defaults].yaml_key[permissions.bypass]||smellytunes.bypass>>
            - if <[playing].is[LESS].than[<[max]>]||true> || <player.has_permission[<[bypass]>]> || <player.is_op>:
              - define redstone:<yaml[sc_tu].read[settings.redstone]||<script[sc_tu_defaults].yaml_key[settings.redstone]||false>>
              - if <[redstone].not.or[<context.location.power.is[MORE].than[0]>]>:
                - if <player.gamemode.id.is[==].to[0]>:
                  - take <context.item>
                - yaml set jukeboxes.<context.location.simple>.track:<context.item.nbt[smellytunes]> id:sc_tu_jb
                - yaml set jukeboxes.<context.location.simple>.scriptname:<context.item.scriptname> id:sc_tu_jb
                - yaml set jukeboxes.<context.location.simple>.state:playing id:sc_tu_jb
                - yaml set jukeboxes.<context.location.simple>.queue:<queue> id:sc_tu_jb
                - yaml set sc_tu.playcount.<context.item.scriptname>:++ id:sc_<player.uuid>
                - yaml set sc_tu.playing:++ id:sc_cache
                - define range:<yaml[sc_tu].read[settings.range]||<script[sc_tu_defaults].yaml_key[settings.range]||5>>
                - define volume:<tern[<[redstone]>].pass[<context.location.power.min[<[range]>]>].fail[<[range]>]>
                - define feedback:<yaml[sc_tu].read[messages.playing]||<script[sc_tu_defaults].yaml_key[messages.playing]||&cError>><&sp><context.item.display.strip_color||&cUnknown>
                - inject <script[<yaml[sc_tu].read[scripts.narrator]||<script[sc_tu_defaults].yaml_key[scripts.narrator]||sc_common_feedback>>]>
                - define dir:<yaml[sc_tu].read[settings.dir]||<script[sc_tu_defaults].yaml_key[settings.dir]||smellytunes>>
                - ~midi file:<[dir]>/<context.item.nbt[smellytunes]> <context.location> volume:<[volume]>
                - yaml set jukeboxes.<context.location.simple>.state:finished id:sc_tu_jb
                - yaml set sc_tu.playing:-- id:sc_cache
              - else:
                - define feedback:<yaml[sc_tu].read[messages.nosignal]||<script[sc_tu_defaults].yaml_key[messages.nosignal]||&cError>>
            - else:
              - define feedback:<yaml[sc_tu].read[messages.playcount]||<script[sc_tu_defaults].yaml_key[messages.playcount]||&cError>>
          - else:
            - define feedback:<yaml[sc_tu].read[messages.permission]||<script[sc_tu_defaults].yaml_key[messages.permission]||&cError>>
        - if <[feedback].exists>:
          - inject <script[<yaml[sc_tu].read[scripts.narrator]||<script[sc_tu_defaults].yaml_key[scripts.narrator]||sc_common_feedback>>]>
        on player breaks jukebox:
        - define namespace:sc_tu
        - inject <script[sc_tu_eject]>
sc_tu_eject:
    type: task
    debug: false
    script:
    - foreach <yaml[sc_tu_jb].list_keys[jukeboxes]> as:jukebox:
      - if <[jukebox].matches[<context.location.simple>]>:
        - determine passively cancelled
        - midi cancel <context.location>
        - queue <yaml[sc_tu_jb].read[jukeboxes.<[jukebox]>.queue]> stop
        - drop <item[<yaml[sc_tu_jb].read[<[jukebox]>.scriptname]>]> <context.location.relative[0,1,0]>
        - yaml set jukeboxes.<[jukebox]>:! id:sc_tu_jb
        - stop
sc_tu_defaults:
  type: yaml data
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
    updater: sc_common_update
  messages:
    prefix: '&9[&aSmelly&2Tunes&9]'
    permission: '&cYou don''t have permission.'
    description: 'Interfaces with the Smellytunes plugin.'
    reload: '&9Plugin has been successfully reloaded.'
    wait: '&9Please wait...'
    playing: '&9Now playing:'
    playcount: '&cToo many songs playing.'
    nosignal: '&cRedstone signal required.'
    enabled: '&9Plugin has been &cenabled&9.'
    disabled: '&9Plugin has been &cdisabled&9.'
    titlecolor: &a
    lorecolor: &9
