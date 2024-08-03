;; [on-key.fnl]
;; On-keypress mode

(local {: get-locations} (require :eyeliner.liner))
(local {: opts} (require :eyeliner.config))
(local {: ns-id
        : clear-eyeliner
        : apply-eyeliner
        : dim
        : disable-filetypes
        : disable-buftypes} (require :eyeliner.shared))
(local utils (require :eyeliner.utils))

(import-macros {: when-enabled} :fnl/eyeliner/macros)

(fn on-key [key]
  (let [line (utils.get-current-line)
        [y x] (utils.get-cursor)
        dir (if (or (= key "f") (= key "t")) :right :left)
        to-apply (get-locations line x dir)]
    ;; Apply eyeliner right after pressing key
    (if opts.dim (dim y x dir))
    (apply-eyeliner y to-apply)
    ;; Draw fake cursor, since getcharstr() will move the real cursor away
    (utils.add-hl ns-id "Cursor" x)
    (vim.cmd ":redraw") ; :redraw to show Cursor highlight
    ;; Simulate normal "f" process
    (clear-eyeliner y)
    key))

(fn enable-keybinds []
  (when-enabled
    (each [_ key (ipairs ["f" "F" "t" "T"])]
      (vim.keymap.set ["n" "x" "o"]
                      key
                      (fn [] (on-key key))
                      {:expr true :buffer 0}))))

(fn remove-keybinds []
  (when-enabled
    (each [_ key (ipairs ["f" "F" "t" "T"])]
       (vim.keymap.del ["n" "x" "o"] key {:buffer 0}))))


(fn enable []
  (if opts.debug (vim.notify "On-keypress mode enabled"))
  (disable-filetypes)
  (disable-buftypes)
  (enable-keybinds)
  (utils.set-autocmd ["BufEnter" "BufWinEnter"]
                     {:callback enable-keybinds
                      :group "Eyeliner"})
  (utils.set-autocmd ["BufLeave" "BufWinLeave"]
                     {:callback remove-keybinds
                      :group "Eyeliner"}))


{: enable : remove-keybinds}
