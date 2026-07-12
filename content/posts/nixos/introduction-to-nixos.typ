#import "/templates/post.typ": post, img, columns

#let args = (
  title: "Nix 和 NixOS 介紹",
  date: "2026-07-06",
  author: "Justin",
  tags: ("Nix","NixOS"),
  order: 1,
)

#show: post.with(..args)


我目前已經使用 NixOS 作爲日常生活、娛樂、工作的主力系統兩年左右。
雖然官方有文檔，現在也有許多教學文章和影片，
但 NixOS 對於一班使用者來說，還是一個學習曲線非常陡峭的一個Linux Distribution。
所以我打算為中文社區貢獻一點微薄之力。

在本站更新的 NixOS 教學將以我日常使用的實踐和心得，盡量簡單的讓初學者可以簡單上手。


= What is Nix and NixOS ?

Nix 是一個funtional programming language。
有點像是 Haskell ，這類語言強調的是 pure function，也就是函數在相同的輸入下會有一樣的輸出。
Nix package manager 是使用 Nix 作爲語言的包管理器。
而 NixOS 就是使用 Nix packge manager 的作業系統（ 像是 apt in Debian, pacman in Arch ）。

然而 Nix 可不止 是一般的包管理器，除了安裝軟體外，還能夠管理各種不同程式的 Config 檔案和各種 System 的設定， 
包括 network, hardware, filesystem, booting, ...。
在 NixOS 中 這些 config 會用 Nix language 寫成， 記錄在電腦裡面。

以上性質引出一個最重要的特性： Reproducible， 只要 有 config 就算電腦重灌，還是能完整復原。
同時因爲所有設定和軟體安裝都是寫在檔案裡的，因此我們可以很簡單的檢查我們裝了什麼、改了什麼設定。

= Why NixOS ?

在受到  Windows 的摧殘後，過去幾年，我一直想把作業系統換到  Linux 。
但是我之前曾經在虛擬機用過  Ubuntu, Debian ，我覺得如果完全切換過去我大概很快就會把電腦搞炸。
有天在 Thread 上看到有人推薦  NixOS ，我就查了一下，然後就被深深吸引了，決定來試試看 （ 沒錯， NixOS 是我第一次使用 Linux 作為日常使用）。

我是先做 NixOS 的 LiveUSB 先是用幾個月確定沒問題後才把 Windows 移除。
NixOS 可復現的特性與回滾的能力，讓我在設定系統時完全不用擔心把系統搞壞，尤其在我設定 Hyprland 時。
在從 LiveUSB 到覆蓋硬碟時，重裝系統只用下一行指令就能我全重現在 LiveUSB 上的體驗，包括軟體和所有設定。
除了這點外， NixOS 還有很多方便的命令行工具，可以在開發還有測試上有更好地體驗。


