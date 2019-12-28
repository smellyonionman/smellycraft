###########################################
# Made by Smellyonionman for Smellycraft. #
#          onion@smellycraft.com          #
#    Tested on Denizen-1.1.2-b4492-DEV    #
#               Version 1.1               #
#-----------------------------------------#
#     Updates and notes are found at:     #
#     https://smellycraft.com/denizen     #
#-----------------------------------------#
#    You may use, modify or share this    #
#    script, provided you don't remove    #
#    or alter lines 1-13 of this file.    #
###########################################
sc_common_init:
    type: task
    debug: false
    script:
    - define namespace:sc_common
    - define targets:!|:<server.list_online_players.filter[is_op]||null>
    - if <server.has_file[../Smellycraft/common.yml]||false>:
      - if <yaml.list.contains[sc_common]>:
        - ~yaml unload id:sc_common
      - ~yaml load:../Smellycraft/common.yml id:sc_common
    - else:
      - ~yaml create id:sc_common
      - define payload:<script[sc_common_defaults].to_json||null>
      - if <[payload].matches[false]>:
        - ~webget https://raw.githubusercontent.com/smellyonionman/smellycraft/master/configs/common.yml save:sc_raw headers:host/smellycraft.com:443|user-agent/smellycraft
        - define payload:<entry[sc_raw].result>
      - ~yaml loadtext:<[payload]> id:sc_common
      - yaml set type:! id:sc_common
      - ~yaml savefile:../Smellycraft/common.yml id:sc_common
      - yaml set version:1.1 id:sc_common
    - if <server.has_file[../Smellycraft/schedules.yml]||false>:
      - ~yaml load:../Smellycraft/schedules.yml id:sc_schedules
    - else:
      - ~yaml create id:sc_schedules
      - ~yaml savefile:../Smellycraft/schedules.yml id:sc_schedules
    - foreach <server.list_online_players>:
      - adjust <queue> linked_player:<player[<[value]>]>
      - if <server.has_file[../Smellycraft/playerdata/<player.uuid>.yml].not>:
        - yaml create id:sc_<player.uuid>
      - else:
        - yaml load:../Smellycraft/playerdata/<player.uuid>.yml id:sc_<player.uuid>
    - if <yaml.list.contains[sc_cache].not||false>:
      - yaml create id:sc_cache
    - if <yaml.list.contains[sc_pcache].not||false>:
      - yaml create id:sc_pcache
    - define feedback:<yaml[sc_common].read[messages.admin.reload]||<script[sc_common_defaults].yaml_key[messages.admin.reload]>>
    - inject <script[<yaml[sc_common].read[scripts.narrator]||<script[sc_common_defaults].yaml_key[scripts.narrator]sc_common_feedback>>]>
sc_common_cmd:
    type: command
    debug: false
    name: smellycraft
    description: <yaml[sc_common].read[messages.command.desc]||<script[sc_common_defaults].yaml_key[messages.command.desc]||Global settings for Smellycraft plugins.>>
    usage: /smellycraft
    script:
    - define namespace:sc_common
    - define admin:<yaml[sc_common].read[permissions.admin]||script[sc_common_defaults].yaml_key[permissions.admin]||smellycraft.admin>>
    - if <context.args.size.is[==].to[1]||false>:
      - if <context.args.get[1].to_lowercase.matches[(save|update|reload)]||false>:
        - define filename:common.yml
        - inject <script[sc_common_datacmd]>
      - else if <context.args.get[1].to_lowercase.matches[set]||false>:
        - define placeholder:<yaml[sc_common].read[messages.admin.args_m]||<script[sc_common_defaults].yaml_key[messages.admin.args_m]||&cError>>
        - define feedback:<element[<[placeholder]>].replace[[args]].with[&ltsetting&gt&sp(&ltsubsetting&gt)&sp&ltstate&gt]>
      - else:
        - define placeholder:<yaml[sc_common].read[messages.admin.args_i]||<script[sc_common_defaults].yaml_key[messages.admin.args_i]||&cError>>
        - define feedback:<[placeholder].replace[[args]].with[<context.args.get[1]>]>
    - else if <context.args.size.is[==].to[2]||false>:
      - if <context.args.get[1].to_lowercase.matches[set]||false>:
        - define placeholder:<yaml[sc_common].read[messages.admin.args_m]||<script[sc_common_defaults].yaml_key[messages.admin.args_m]||&cError>>
        - define feedback:<element[<[placeholder].replace[[args]].with[(&ltsubsetting&gt)&sp&ltstate&gt]>]>
      - else:
        - define placeholder:<yaml[sc_common].read[messages.admin.args_i]||<script[sc_common_defaults].yaml_key[messages.admin.args_i]||&cError>>
        - define feedback:<[placeholder].replace[[args]].with[<context.args.get[1]>]>
    - else if <context.args.size.is[==].to[3]||false>:
      - if <context.args.get[1].to_lowercase.matches[set]||false>:
        - if <context.args.get[2].to_lowercase.matches[update]>:
          - if <context.args.get[3].to_lowercase.matches[(true|false)]||false>:
            - if <player.has_permission[<[admin]>]||false> || <player.is_op||false> || <context.server>:
              - yaml set settings.<context.args.get[2].to_lowercase>:<context.args.get[3].to_lowercase> id:sc_common
              - define placeholder:<yaml[sc_common].read[messages.admin.set]||<script[sc_common_defaults].yaml_key[messages.admin.set]||&cError>>
              - define feedback:<[placeholder].replace[[setting]].with[<context.args.get[2].to_lowercase>].replace[[state]].with[<context.args.get[3].to_lowercase>]>
            - else:
              - define feedback:<yaml[sc_common].read[messages.permission]||<script[sc_common_defaults].yaml_key[messages.permission]||&cError>>
          - else:
            - define feedback:<yaml[sc_common].read[messages.admin.boolean]||<script[sc_common_defaults].yaml_key[messages.admin.boolean]||&cError>>
        - else if <context.args.get[2].to_lowercase.matches[feedback]||false>:
          - if <context.args.get[3].to_lowercase.matches[(chat|actionbar|custom)]>:
            - define arg:<context.args.get[3].to_lowercase>
            - yaml set settings.<context.args.get[2].to_lowercase>:<[arg]> id:sc_common
            - define placeholder:<yaml[sc_common].read[messages.admin.set]||<script[sc_common_defaults].yaml_key[messages.admin.set]||&cError>>
            - define feedback:<[placeholder].replace[[setting]].with[<context.args.get[2].to_lowercase>].replace[[state]].with[<tern[<[arg].to_lowercase.matches[false]>].pass[&c].fail[&a]><[arg]>]>
          - else:
            - define placeholder:<yaml[sc_common].read[messages.admin.args_i]||<script[sc_common_defaults].yaml_key[messages.admin.args_i]||&cError>>
            - define feedback:<[placeholder].replace[[args]].with[<context.args.remove[1|2].separated_by[,&sp]>]>
        - else:
          - define placeholder:<yaml[sc_common].read[messages.admin.args_i]||<script[sc_common_defaults].yaml_key[messages.admin.args_i]||&cError>>
          - define feedback:<[placeholder].replace[[args]].with[<context.args.remove[1|3].separated_by[,&sp]>]>
      - else:
        - define placeholder:<yaml[sc_common].read[messages.admin.args_i]||<script[sc_common_defaults].yaml_key[messages.admin.args_i]||&cError>>
        - define feedback:<[placeholder].replace[[args]].with[<context.args.remove[2|3].separated_by[,&sp]>]>
    - if <[feedback].exists>:
      - inject <script[<yaml[sc_common].read[scripts.narrator]||<script[sc_common_defaults].yaml_key[scripts.narrator]||sc_common_feedback>>]>
sc_common_datacmd:
    type: task
    debug: false
    script:
    - if <player.has_permission[<[admin]>]||false> || <player.is_op||false> || <context.server>:
      - inject <script[<yaml[sc_<[namespace]>].read[scripts.<context.args.get[1]>]||<script[<[namespace]>_defaults].yaml_key[scripts.<context.args.get[1]>]||sc_common_<tern[<context.args.get[1].to_lowercase.matches[reload]>].pass[init].fail[<context.args.get[1]>]>>>]>
      - stop
    - else:
      - define feedback:<yaml[<[namespace]>].read[messages.permission]||<script[sc_common_defaults].yaml_key[messages.permission]||&cError>>
#####################################
#  DEWEY DECIMAL VERSIONING SYSTEM  #
#####################################
sc_common_update:
    type: task
    debug: true
    definitions: namespace
    script:
    - ~webget https://smellycraft.com/denizen/update save:sc_versions headers:host/smellycraft.com:443|user-agent/smellycraft
    - define feedback:!
    - if <entry[sc_versions].failed>:
      - define feedback:<yaml[sc_common].read[messages.update.failed]||<script[sc_common_defaults].yaml_key[messages.update.failed]>>
    - else:
      - ~yaml loadtext:<entry[sc_versions].result> id:sc_versions
      - define local:!|:<yaml[<[namespace]>].read[version].split[.]||0>
      - define remote:!|:<yaml[sc_versions].read[plugins.<[namespace]>.version].split[.]||-1>
      - foreach <[local]||null>:
        - if <[value].is[LESS].than[<[remote].get[<[loop_index]>]>]>:
          - define new:true
          - foreach stop
        - else:
          - foreach stop
      - if <[new]||false>:
        - define placeholder:<yaml[sc_common].read[messages.update.notice]||<script[sc_common_defaults].yaml_key[messages.update.notice]||&cError>>
        - define feedback:<[placeholder].replace[[version]].with[<[remote].separated_by[.]>].replace[[url]].with[<yaml[sc_versions].read[plugins.<[namespace]>.url]>]>
    - if <[feedback].exists>:
      - inject <script[<yaml[sc_common].read[scripts.narrator]||<script[sc_common_defaults].yaml_key[scripts.narrator]||sc_common_feedback>>]>
    - if <yaml.list.contains[sc_versions]>:
      - ~yaml unload id:sc_versions
#####################################
#  FEEDBACK: NARRATE OR ACTIONBAR?  #
#####################################
sc_common_feedback:
    type: task
    debug: false
    definitions: namespace|feedback|targets
    script:
    - if <[targets].exists.not>:
      - define targets:<player||null>
    - if <[targets].matches[null]>:
      - stop
    - define prefix:<yaml[<[namespace]>].read[messages.prefix]||<script[<[namespace]>_defaults].yaml_key[messages.prefix]||&9&lb&aSmelly&2craft&9&rb]>>
    - if <yaml[sc_common].read[settings.feedback.force]||false>:
      - if <yaml[sc_common].read[settings.feedback.mode].matches[chat|narrate]||true>:
        - define men_of_talk:!|:<[targets]>
      - else:
        - define men_of_action:!|:<[targets]>
    - else:
      - foreach <[targets]>:
        - if <yaml[sc_<[value].as_player.uuid>].read[smellycraft.options.feedback].matches[chat|narrate]||true>:
          - define men_of_talk:|:<[value].as_player>
        - else:
          - define men_of_action:|:<[value].as_player>
    - if <[men_of_talk].exists>:
      - narrate <element[<[prefix]>&sp<list[<[feedback]>].separated_by[&sp]||&cError>].unescaped.parse_color.parsed> targets:<[men_of_talk]>
    - if <[men_of_action].exists>:
      - foreach <[feedback]>:
        - actionbar <element[<[value]||&cError>].unescaped.parse_color.parsed> targets:<[men_of_action]>
        - wait <duration[<yaml[sc_common].read[settings.readingtime]||<script[sc_common_defaults].yaml_key[settings.readingtime]||1.5s>>]>
    - define feedback:!
#####################################
# MARQUEE: ANIMATED MENU TITLE TEXT #
#####################################
sc_common_marquee:
    type: task
    debug: false
    definitions: title|wait|inv
    script:
    - repeat <[title].size>:
      - inventory open d:in@generic[size=<context.inventory.size||<[inv].size>>;contents=null;title=<[title].get[<[value]>].unescaped.parse_color>]
      - wait <duration[<[wait]||<yaml[sc_common].read[settings.readingtime]||<script[sc_common_defaults].yaml_key[settings.readingtime]||1.5s>>>]>
    - define title:!
    - inventory open d:<context.inventory||<[inv]>>
sc_common_listener:
    type: world
    debug: false
    events:
        on reload scripts:
        - if <server.has_file[../Smellycraft/common.yml].not>:
          - inject <script[sc_common_init]>
        on server start priority:-1:
        - inject <script[sc_common_init]>
        on player join:
        - if <yaml.list.contains[sc_<player.uuid>].not>:
          - if <server.has_file[../Smellycraft/playerdata/<player.uuid>.yml]>:
            - ~yaml load:../Smellycraft/playerdata/<player.uuid>.yml id:sc_<player.uuid>
          - else:
            - ~yaml create id:sc_<player.uuid>
        on player quits:
        - if <yaml.list.contains[sc_<player.uuid>]>:
          - yaml savefile:../Smellycraft/playerdata/<player.uuid>.yml id:sc_<player.uuid>
          - yaml unload id:sc_<player.uuid>
        - yaml set <player.uuid>:! id:sc_pcache
        on shutdown:
        - define namespace:sc_common
        - define filename:common.yml
        - inject <script[sc_common_save]>
        on delta time hourly:
        - define namespace:sc_common
        - define filename:common.yml
        - inject <script[sc_common_save]>
        - if <yaml[sc_common].read[settings.update].to_lowercase.matches[true|enabled]||false>:
          - inject <script[<yaml[sc_common].read[scripts.update]||<script[sc_common_defaults].yaml_key[scripts.update]||sc_common_update>>]>
sc_common_save:
    type: task
    debug: false
    definitions: namespace|filename
    script:
    - if <yaml.list.contains[<[namespace]>]||false>:
      - yaml savefile:../Smellycraft/<[filename]> id:<[namespace]>
    - if <[namespace].matches[sc_common]>:
      - if <yaml.list.contains[sc_schedules]||false>:
        - yaml savefile:../Smellycraft/schedules.yml id:sc_schedules
      - foreach <server.list_online_players>:
        - if <yaml.list.contains[sc_<[value].uuid>]>:
          - ~yaml savefile:../Smellycraft/playerdata/<[value].uuid>.yml
    - if <[feedback].exists>:
      - define feedback:<yaml[sc_common].read[messages.admin.saved]||<script[sc_common].yaml_key[messages.admin.saved]||&cError>>
      - inject <script[<yaml[<[namespace]>].read[scripts.narrator]||<script[<[namespace]>_defaults].yaml_key[scripts.narrator]||sc_common_feedback>>]>
      - define feedback:!
sc_common_defaults:
  type: yaml data
  settings:
    update: true
    feedback: custom
    readingtime: 1.5s
  scripts:
    narrator: sc_common_feedback
    GUI: sc_common_marquee
    update: sc_common_update
  permissions:
    admin: smellycraft.admin
  messages:
    prefix: '&9[&aSmellycraft&9]'
    permission: '&cYou don''t have permission.'
    admin:
      saved: '&9Data was saved.'
      reload: '&9Common files have been reloaded.'
      set: '&a[setting] &9has been set to [state]&9.'
      args_m: '&cMissing arguments: [args]'
      args_i: '&cInvalid arguments: [args]'
      boolean: '&cPlease specify true or false.'
      disabled: '&cPlugin is currently disabled.'
    update:
      notice: '&9Version &6[version] &9available at &a[url]'
      failed:
      - '&cVersion could not be checked.'
      - '&9Try visiting the repository:'
      - '&ahttps://smellycraft.com/denizen'
      enabled: '&aUpdates enabled.'
      enabled-no: '&9Updates are already enabled.'
      disabled: '&cUpdates disabled.'
      disabled-no: '&9Updates are already disabled.'
      specify: '&cPlease specify enable or disable.'
