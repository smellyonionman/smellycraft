###########################################
# Made by Smellyonionman for Smellycraft. #
#          onion@smellycraft.com          #
#    Tested on Denizen-1.1.2-b4492-DEV    #
#               Version 1.0               #
#-----------------------------------------#
#     Updates and notes are found at:     #
#  https://d.smellycraft.com/smellyboard  #
#-----------------------------------------#
#    You may use, modify or share this    #
#    script, provided you don't remove    #
#    or alter lines 1-13 of this file.    #
###########################################
sc_sb_init:
    type: task
    debug: false
    script:
    - define namespace:sc_sb
    - define admin:<yaml[sc_sb].read[permissions.admin]||<script[sc_sb_defaults].yaml_key[permissions.admin]||smellyboard.admin>>
    - define targets:<server.list_online_players.filter[has_permission[<[admin]>]].include[<server.list_online_ops>].deduplicate||<player>>
    - if <server.has_file[../Smellycraft/smellyboard.yml]||null>:
      - ~yaml load:../Smellycraft/smellyboard.yml id:sc_sb
    - else:
      - ~yaml create id:sc_sb
      - define payload:<script[sc_sb_defaults].to_json||null>
      - if <[payload].matches[null]>:
        - ~webget https://raw.githubusercontent.com/smellyonionman/smellycraft/master/configs/smellyboard.yml save:sc_raw headers:host/smellycraft.com:443|user-agent/smellycraft
        - define payload:<entry[sc_raw].result>
      - ~yaml loadtext:<[payload]> id:sc_sb
      - yaml set type:! id:sc_sb
    - foreach <yaml[sc_sb].list_keys[scripts]||<script[sc_sb_defaults].list_keys[scripts]||<list[]>>> as:task:
      - if <server.object_is_valid[<script[<yaml[sc_sb].read[scripts.<[task]>]||<script[sc_sb_defaults].yaml_key[scripts.<[task]>]>>]>].not>:
        - define placeholder:<yaml[sc_sb].read[messages.missing_script]||<script[sc_sb_defaults].yaml_key[messages.missing_script]||&cError>>
        - narrate '<[placeholder].replace[[script]].with[<[task]>].separated_by[&sp].unescaped.parse_color>'
        - stop
    - ~yaml savefile:../Smellycraft/smellyboard.yml id:sc_sb
    - yaml set version:1.0 id:sc_sb
    - ~yaml create id:sc_sb_linetemp
    - ~yaml loadtext:<script[sc_sb_lines].to_json> id:sc_sb_linetemp
    - yaml set type:! id:sc_sb_linetemp
    - foreach <yaml[sc_sb_linetemp].list_keys[]>:
      - if <yaml[sc_sb].read[lines.<[value]>]||false>:
        - yaml id:sc_sb_linetemp copykey:<[value]> custom.<[value]> to_id:sc_sb
    - define feedback:<yaml[sc_sb].read[messages.reload]||<script[sc_sb_defaults].yaml_key[messages.reload]||&cError>>
    - inject <script[<yaml[sc_sb].read[scripts.narrator]||<script[sc_sb_defaults].yaml_key[scripts.narrator]||sc_common_narrator>>]>
sc_sb_cmd:
    type: command
    debug: false
    name: smellyboard
    description: <yaml[sc_sb].read[messages.description]||Interfaces with the Smellyboard plugin.>
    usage: /smellyboard ( reload | credits | update ( enable | disable ) | freq | max )
    aliases:
    - sidebar
    script:
    - define namespace:sc_sb
    - define admin:<yaml[sc_sb].read[permissions.admin]||<script[sc_sb_defaults].yaml_key[permissions.admin]||smellyboard.admin>>
    - if <context.args.size.is[==].to[0]||false>:
      - if <player.has_permission[<yaml[sc_sb].read[permissions.use]||<script[sc_sb_defaults].yaml_key[permissions.use]||smellyboard.use>>]>:
        - yaml set <player.uuid>.sc_sb.index:1 id:sc_pcache
        - inventory open d:<inventory[sc_sb_menu]>
      - else:
        - define feedback:<yaml[sc_sb].read[messages.permission]||<script[sc_sb_defaults].yaml_key[messages.permission]||&cError>>
    - else if <context.args.size.is[MORE].than[0]||false>:
      - if <context.args.get[1].to_lowercase.matches[reload]||false>:
        - if <player.has_permission[<[admin]>]||false> || <player.is_op||false> || <context.server>:
          - inject <script[sc_sb_init]>
          - stop
        - else:
          - define feedback:<yaml[sc_sb].read[messages.permission]||<script[sc_sb_defaults].yaml_key[messages.permission]||&cError>>
      - else if <context.args.get[1].to_lowercase.matches[credits]>:
        - define feedback:&9made&spby&spyour&spfriend&sp&6smellyonionman&nl&9Go&spto&sp&ahttps&co//smellycraft.com/smellyboard&sp&9for&spinfo
      - else if <context.args.get[1].to_lowercase.matches[update]||false>:
        - if <player.has_permission[<[admin]>]||false> || <player.is_op||false> || <context.server>:
          - if <context.args.size.is[OR_MORE].than[2]||false>:
            - if <context.args.get[2].to_lowercase.matches[enable]||false>:
              - if <yaml[sc_sb].read[settings.update].matches[(true|enabled)]||false>:
                - define feedback:<yaml[sc_sb].read[messages.update.enabled-no]||<script[sc_sb_defaults].yaml_key[messages.update.enabled-no]||&cError>>
              - else:
                - yaml set settings.update:true id:sc_sb
                - define feedback:<yaml[sc_sb].read[messages.update.enabled]||<script[sc_sb_defaults].yaml_key[messages.update.enabled]||&cError>>
            - else if <context.args.get[2].to_lowercase.matches[disable]||false>:
              - if <yaml[sc_sb].read[settings.update].matches[(true|enabled)].not||false>:
                - define feedback:<yaml[sc_sb].read[messages.update.disabled-no]||||<script[sc_sb_defaults].yaml_key[messages.update.disabled-no]||&cError>>>
              - else:
                - yaml set settings.update:false id:sc_sb
                - define feedback:<yaml[sc_sb].read[messages.update.disabled]||<script[sc_sb_defaults].yaml_key[messages.update.disabled]||&cError>>
            - else:
              - define feedback:<yaml[sc_sb].read[messages.update.specify]||<script[sc_sb_defaults].yaml_key[messages.update.specify]||&cError>>
          - else:
            - inject <script[<yaml[sc_sb].read[scripts.updater]||<script[sc_sb_defaults].yaml_key[scripts.updater]||sc_common_updater>>]>
            - stop
        - else:
          - define feedback:<yaml[sc_sb].read[messages.permission]||<script[sc_sb_defaults].yaml_key[messages.permission]||&cError>>
      - else if <context.args.get[1].to_lowercase.matches[(freq|max)]||false>:
        - if <player.has_permission[<[admin]>]||false> || <player.is_op||false> || <context.server>:
          - if <context.args.get[2].is_decimal||false>:
            - define val:<context.args.get[2].round_down.max[1]||3>
            - yaml set settings.<context.args.get[1].to_lowercase>:<[val]||3> id:sc_sb
          - else:
            - define feedback:<yaml[sc_sb].read[messages.update.numeric]||<script[sc_sb_defaults].yaml_key[messages.update.numeric]||&cError>>
        - else:
          - define feedback:<yaml[sc_sb].read[messages.permission]||<script[sc_sb_defaults].yaml_key[messages.permission]||&cError>>
    - if <[feedback].exists>:
      - inject <script[<yaml[sc_sb].read[scripts.narrator]||<script[sc_sb_defaults].yaml_key[scripts.narrator]||sc_common_narrator>>]>
sc_sb_events:
    type: world
    debug: false
    events:
        on reload scripts:
        - if <server.has_file[../Smellycraft/smellyboard.yml].not||null>:
          - inject <script[sc_sb_init]>
        on server start priority:1:
        - inject <script[sc_sb_init]>
        on shutdown:
        - ~yaml savefile:../Smellycraft/smellyboard.yml id:sc_sb
        - yaml unload id:sc_sb
        - foreach <yaml[sc_<player.uuid>].list_keys[smellyboard.lines]||null>:
          - if <yaml[sc_sb].read[lines.<[value]>].matches[true|enabled]||null> foreach next
            ~yaml set smellyboard.lines.<[value]>:! id:sc_<player.uuid>
        - yaml set smellyboard.listener:false id:sc_<player.uuid>
        on delta time hourly:
        - define namespace:sc_sb
        - if <yaml[sc_sb].read[settings.update].to_lowercase.matches[true|enabled]||false>:
          - inject <script[<yaml[sc_sb].read[scripts.updater]||<script[sc_sb_defaults].yaml_key[scripts.updater]||sc_common_updater>>]>
        on delta time secondly:
        - if <yaml.list.contains[sc_sb].not||true>:
          - stop
        - if <util.date.time.second.mod[<yaml[sc_sb].read[settings.freq]||<script[sc_sb_defaults].yaml_key[settings.freq]||5>>].is[==].to[0]||false>:
          - stop
        - foreach <server.list_online_players> as:player:
          - adjust <queue> linked_player:<[player]>
          - if <yaml[sc_<player.uuid>].list_keys[smellyboard.lines].size.is[MORE].than[0]||null>:
            - foreach <yaml[sc_<player.uuid>].list_keys[smellyboard.lines]> as:key:
              - define var:<yaml[sc_<player.uuid>].read[smellyboard.lines.<[key]>]||false>
              - define output:|:<yaml[sc_sb].read[custom.<[key]>.output].parsed||&cError>
            - sidebar set title:<yaml[sc_sb].read[messages.title].unescaped.parse_color||<&7>Smellyboard> values:<[output].parse_color> players:<player>
          - else:
            - sidebar remove players:<player>
        on player drags in sc_sb_menu:
        - determine cancelled
        on player clicks in sc_sb_menu:
        - determine passively cancelled
        - define type:<context.item.nbt[type]||null>
        - if <[type].matches[null]||false>:
          - stop
        - else if <[type].matches[prev|next]||null>:
          - define index:<context.item.nbt[data]>
          - yaml set <player.uuid>.sc_sb.index:<[index]> id:sc_pcache
        - else if <[type].matches[line]||false>:
          - define line:<context.item.nbt[data]>
          - define enabled:<yaml[sc_<player.uuid>].list_keys[smellyboard.lines].contains[<[line]>]||false>
          - if <yaml[sc_<player.uuid>].list_keys[smellyboard.lines].size.is[OR_MORE].than[<yaml[sc_sb].read[settings.max]>]||false>:
            - if <[enabled].not>:
              - define title:<yaml[sc_sb].read[messages.limit]||<script[sc_sb_defaults].yaml_key[settings.freq]||&cError>>
              - inject <script[<yaml[sc_sb].read[scripts.GUI]||<script[sc_sb_defaults].yaml_key[scripts.GUI]||sc_common_marquee>>]>
              - stop
          - if <context.item.nbt[listener].matches[false].not||false>:
            - if <[enabled].not||false>:
              - yaml set smellyboard.listener:<[line]> id:sc_<player.uuid>
              - inventory close d:<inventory[sc_sb_menu]>
              - define placeholder:<yaml[sc_sb].read[messages.linename]||<script[sc_sb_defaults].yaml_key[messages.linename]||&cError>>
              - define feedback:<[placeholder].replace[[line]].with[<[line]>]>
              - inject <script[<yaml[sc_sb].read[scripts.narrator]||<script[sc_sb_defaults].yaml_key[scripts.narrator]||sc_common_narrator>>]>
              - stop
            - inject <script[sc_sb_toggle]>
          - else:
            - inject <script[sc_sb_toggle]>
        - inventory open d:<inventory[sc_sb_menu]>
        on player chats:
        - define namespace:sc_sb
        - if <yaml[sc_<player.uuid>].map_get[smellyboard.listener].matches[false].not||false>:
          - determine passively cancelled
          - if <context.message.to_lowercase.matches[cancel.*]>:
            - define feedback:<yaml[sc_sb].read[messages.cancelled]||<script[sc_sb_defaults].yaml_key[messages.cancelled]||&cError>>
            - inject <script[<yaml[sc_sb].read[scripts.narrator]||<script[sc_sb_defaults].yaml_key[scripts.narrator]||sc_common_narrator>>]>
            - stop
          - else:
            - define line:<yaml[sc_<player.uuid>].read[smellyboard.listener]||null>
            - define enabled:false
            - define feedback:<element[&7Set to &o<context.message>.].unescaped.parse_color>
            - define var:<context.message>
          - if <[feedback].exists>:
            - inject <script[<yaml[sc_sb].read[scripts.narrator]||<script[sc_sb_defaults].yaml_key[scripts.narrator]||sc_common_narrator>>]>
          - inject <script[sc_sb_toggle]>
          - yaml set smellyboard.listener:false id:sc_<player.uuid>
sc_sb_toggle:
    type: task
    debug: false
    script:
    - if <[enabled]||false>:
      - yaml set smellyboard.lines.<[line]>:! id:sc_<player.uuid||null>
    - else:
      - yaml set smellyboard.lines.<[line]>:<[var]||null> id:sc_<player.uuid||null>
    - inventory open d:<inventory[sc_sb_menu]>
sc_sb_menu:
    type: inventory
    debug: false
    title: <yaml[sc_sb].read[messages.menu].unescaped.parse_color||<&c>Error>
    size: 9
    procedural items:
    - define index:<yaml[sc_pcache].read[<player.uuid>.sc_sb.index]||1>
    - if <[index].is[MORE].than[1]||false>:
      - define prev:<item[spectral_arrow].with[display_name=&aPrev&spPage;nbt=type/prev|data/<[index].sub[7]>]>
    - else:
      - define prev:<item[arrow].with[display_name=&7End&spof&splist;nbt=type/null|data/<[index]>]>
    - define icons:|:<[prev]>
    - define items:<yaml[sc_sb].list_keys[custom].alphanumeric>
    - define range:<[items].get[<[index]>].to[<[index].add[7].sub[1]>]>
    - foreach <[range]||<list[]>> as:node:
      - define perms:!|:<yaml[sc_sb].read[custom.<[node]>.permissions]||<list[]>>
      - foreach <[perms]>:
        - if <player.has_permission[<[value]>]||false>:
          - define material:<yaml[sc_sb].read[custom.<[node]>.icon]||air>
          - define display:<yaml[sc_sb].read[custom.<[node]>.display].parsed||&cError>
          - define lore:<yaml[sc_sb].read[custom.<[node]>.lore].parsed||<list[]>>
          - define listener:<yaml[sc_sb].read[custom.<[node]>.input]||false>
          - define icon:<item[<[material]||barrier>].with[display_name=<[display]||&cError>;lore=<[lore]>;nbt=type/line|data/<[node]>|listener/<[listener]>;flags=HIDE_ATTRIBUTES|HIDE_ENCHANTS|HIDE_POTION_EFFECTS]>
          - if <yaml[sc_<player.uuid>].list_keys[smellyboard.lines].contains[<[node]>]||null>:
            - adjust def:icon lore:<[icon].lore.include[<yaml[sc_sb].read[messages.enabled]>]>
            - adjust def:icon enchantments:<list[protection,1]>
          - else:
            - adjust def:icon lore:<[icon].lore.include[<yaml[sc_sb].read[messages.disabled]>]>
          - define icons:|:<[icon]>
          - foreach stop
    - define icons:!|:<[icons].pad_right[8].with[<item[air]>]>
    - if <[items].size.is[MORE].than[<[index].add[7]>]||false>:
      - define next:<item[spectral_arrow].with[display_name=&aNext&spPage;nbt=type/next|data/<[index].add[7]>]>
    - else:
      - define next:<item[arrow].with[display_name=&7End&spof&splist;nbt=type/null|data/<[index]>]>
    - define icons:|:<[next]>
    - determine <[icons].unescaped.parse_color>
sc_sb_lines:
  type: yaml data
  balance:
    icon: emerald
    display: '&aBalance'
    permissions:
    - group.players
    lore:
    - '&9Shows your current balance'
    output: '&9Balance: &6<server.economy.format[<player.money.as_money>]||&cError>'
  waypoint:
    icon: compass
    display: '&aWaypoint'
    permissions:
    - group.players
    lore:
    - '&9Distance in blocks from'
    - '&9your current waypoint'
    output: '&a<player.compass_target.distance[<player.location||null>].round_down||&c?> &9blocks to waypoint'
  exhaustion:
    icon: apple
    display: '&aExhaustion'
    permissions:
    - group.players
    lore:
    - '&9How quickly you are tiring'
    output: '&9Exhaustion: &a<player.exhaustion.round_to[1]||&c?>'
  lag:
    icon: observer
    display: '&aLagometer'
    permissions:
    - group.players
    lore:
    - '&9Displays your current ping'
    - '&9as well as current TPS.'
    output: '&9You: &a<player.ping||&c?>&9ms, Us: &a<server.recent_tps.get[1].round_to[2]||&c?> &9TPS'
  mob:
    icon: zombie_head
    display: '&aMob Counter'
    permissions:
    - group.players
    lore:
    - '&9Useful for AFK mob farms.'
    input: true
    output: '&9<[var].to_titlecase||&cError> Counter: &a<player.location.cursor_on.find.entities[<[var]>].within[2].size||&c?>'
  slime:
    icon: slime_block
    display: '&aSlime Chunks'
    permissions:
    - group.players
    lore:
    - '&9Indicates whether or not'
    - '&9you are in a slime chunk'
    output: '&9Slime Chunk: <tern[<player.location.chunk.spawn_slimes||false>].pass[&aTrue].fail[&cFalse]>'
  power:
    icon: repeater
    display: '&aSignal Power'
    permissions:
    - group.players
    lore:
    - '&9Shows power of cursor block'
    output: '&9Power: &a<player.location.cursor_on.power||&c?>'
  damage:
    icon: diamond_sword
    display: '&aWeapon Damage'
    permissions:
    - group.players
    lore:
    - '&9Shows calculated weapon damage'
    output: '&9Damage: <player.weapon_damage||&c?>'
  item:
    icon: hopper
    display: '&aItem Counter'
    permissions:
    - group.players
    lore:
    - '&9Counts items in your inventory'
    input: true
    output: '&9<[var].as_item.material.name.to_titlecase||&cError>: &a<player.inventory.quantity[<[var]>]||&c?>'
  debug:
    icon: comparator
    display: '&aDenizen Debugger'
    permissions:
    - group.admin
    lore:
    - '&9Indicates debugger status'
    output: '&9Global Debug: <tern[<server.debug_enabled>].pass[&aEnabled].fail[&cDisabled]>'
sc_sb_defaults:
  type: yaml data
  settings:
    enabled: true
    update: true
    max: 3
    freq: 5
  permissions:
    use: smellyboard.use
    bypass: smellyboard.bypass
    admin: smellyboard.admin
  scripts:
    narrator: sc_common_feedback
    GUI: sc_common_marquee
    updater: sc_common_update
  lines:
    balance: true
    waypoint: true
    exhaustion: true
    lag: true
    mob: true
    slime: true
    power: true
    damage: true
    item: true
    debug: true
  messages:
    prefix: '&9[&aSmelly&2Board&9]'
    description: 'Interfaces with the Smellyboard plugin.'
    reload: '&9Smellyboard reloaded.'
    limit: '&cToo many items active'
    title: '&7&lSmellyboard'
    menu: '           &0&lHUD Selector'
    enabled: '&9Currently &aenabled'
    disabled: '&9Currently &cdisabled'
    denied: '&cYou don''t have permission.'
    linename: '&oEnter name of [line]&co'
    cancelled: '&7Input cancelled. Display unaltered.'
    missing_script:
    - '&c Script [script] was not detected.'
    - '&c Installation not complete.'
    - '&c Did you install the common files?'
  custom:
    job:
      icon: iron_pickaxe
      display: '&aJob Stats'
      permissions:
      - group.players
      lore:
      - '&9Displays current &alevel'
      - '&9and &aXP &9for a given Job'
      input: true
      output: '&9<[var].to_titlecase||&cError>: &aLevel &6<player.jobs[<[var]>].xp.level||&c?>&a, &6<player.jobs[<[var]>].xp||&c?> &axp'
