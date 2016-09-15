(import [itchat]
        [time]
        [threading])

(defn wait_confirm [itchat]
  (first
   (drop-while (fn [status]  (when (!= status "200")
                                     (print "status:" status)
                                     (when (= status "408") (.get_QR itchat :enableCmdQR 2))
                                     (.sleep time 0.1)
                                     True) )
               (repeatedly (fn []  (.check_login itchat))))) )
(defn get-users-name [display-name]
  (-> (if display-name (.get_friends itchat :name display-name) [(.get_friends itchat)] ) 
      (->> (map (fn [user] (get user "UserName"))))
      list))

(defn get-user-name-1 [display-name] (-> display-name get-users-name first))
(defn get-groups-name [group-name])
(defn get-group-name-1 [group-name])
(defn get-display-name [user-name]
  (let [user-info (-> itchat (.get_friends :userName user-name))]
    (or (get user-info "DisplayName") (get user-info "NickName")) 
    ))

(defn get-group-display-name [grou-name]
  (let [chatroom (first (filter (fn [chatroom] (= grou-name (.get chatroom "UserName"))) (.get_chatrooms itchat)) ) ]
    (if chatroom (or (.get chatroom "DisplayName") (.get chatroom "NickName")) "") ) )

(doto itchat
      .get_QRuuid
      (.get_QR :enableCmdQR -2) 
      wait_confirm
      .web_init
      .show_mobile_login
      (.get_contract :update True)
      .start_receiving
      )

(defn display-message []
  (while true
    (if* (= (len itchat.__client.storageClass.msgList)  0)
         (.sleep time 1)
         (let [msg (.pop itchat.__client.storageClass.msgList)
               _ (print msg)
               msg-type (or (.get msg "Type" "") ) 
               from-user-name (or (get-user-name-1 (.get msg "FromUserName")) (.get msg "ActualNickName" ""))
               reply-user-name (or (when (!= (get-user-name-1 nil) (.get msg "FromUserName")) (.get msg "FromUserName")) 
                                (.get msg "ToUserName"))
               out-msg (+ from-user-name "->" (get-group-display-name (.get msg "ToUserName"))
                          "[" msg-type "]  "
                          (if (= msg-type "Init")
                            "larluo点击进入，请给他发红包，多关心他..."
                            (if (hasattr (.get msg "Text" "") "__call__") "<发送表情包>"  (.get msg "Text" "")) ) )]
           (print out-msg)
           (.send_msg itchat out-msg reply-user-name)  )  )))

(print "larluo's userName:" (get-user-name-1 nil))
(doto (.Thread threading :target display-message)
      (.setDaemon true)
      .start)

(print "wait user input...")
(read)
; (.send_msg itchat "I'm a robot" (get-user-name-1 "叶良辰"))
; (.send_msg itchat "I'm a robot" (get-user-name-1 "王雪"))
; (.send_msg itchat "i'll offer the service later, coming soon..." "@@6e722ca8cc98f4614bf8c190f1273faa2e25d80cb931576b856dc214793b96b0")
; (.send_msg itchat "i'll offer the service later, coming soon..." "@@81af956f014fafd75fb5529f35319c6b975e29e535f8fbea7d38a01a0536f49f")
; (.send_msg itchat "我是机器人，稍后请会为大家提供服务, 敬请期待" "@@0acc923eb25c4ec6c24a5f38f2140d1902b2d514fa375574df095903acd8f420")
