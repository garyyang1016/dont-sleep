package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"
)

type Config struct {
	PreventSleepInterval int `json:"preventSleepInterval"`
}

var (
	startTime          time.Time
	preventSleepCancel context.CancelFunc
)

func loadConfig() Config {
	fileName := "config.json"
	var config Config
	if _, err := os.Stat(fileName); err == nil {
		data, err := os.ReadFile(fileName)
		if err != nil {
			log.Fatalf("讀取設定檔失敗: %v", err)
		}
		err = json.Unmarshal(data, &config)
		if err != nil {
			log.Fatalf("解析設定檔失敗: %v", err)
		}
		return config
	}
	// 檔案不存在，建立預設設定檔
	config = Config{PreventSleepInterval: 300}
	data, err := json.MarshalIndent(config, "", "  ")
	if err != nil {
		log.Fatalf("建立預設設定內容失敗: %v", err)
	}
	err = os.WriteFile(fileName, data, 0644)
	if err != nil {
		log.Fatalf("寫入設定檔失敗: %v", err)
	}
	log.Println("建立預設設定檔")
	return config
}

func callPreventSleep() {
	mod := syscall.NewLazyDLL("kernel32.dll")
	proc := mod.NewProc("SetThreadExecutionState")
	// 使用旗標: ES_CONTINUOUS (0x80000000) 與 ES_SYSTEM_REQUIRED (0x00000001)
	r, _, err := proc.Call(uintptr(0x80000000 | 0x00000001 | 0x00000002))
	if r == 0 {
		log.Printf("呼叫防休眠 API 失敗: %v", err)
	} else {
		log.Println("呼叫防休眠 API 成功")
	}
}

func preventSleepRoutine(ctx context.Context, interval int) {
	ticker := time.NewTicker(time.Duration(interval) * time.Second)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			log.Println("preventSleep1 goroutine 已終止")
			return
		case <-ticker.C:
			callPreventSleep()
		}
	}
}

func main() {
	statusFlag := flag.Bool("status", false, "查詢程式運行狀態")
	killFlag := flag.String("kill", "", "終止指定工作緒 (使用 -kill preventSleep1)")
	intervalFlag := flag.Int("interval", 0, "設定防休眠間隔時間 (單位：秒)")
	flag.Parse()

	startTime = time.Now()
	config := loadConfig()

	// 如果有提供 interval 參數，則覆蓋設定檔中的值
	if *intervalFlag > 0 {
		config.PreventSleepInterval = *intervalFlag
		log.Printf("使用命令列參數設定的間隔時間: %d 秒", *intervalFlag)
	}

	ctx, cancel := context.WithCancel(context.Background())
	preventSleepCancel = cancel
	go preventSleepRoutine(ctx, config.PreventSleepInterval)

	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-sigs
		log.Println("接收到終止訊號，開始進行優雅關閉")
		cancel()
		os.Exit(0)
	}()

	if *statusFlag {
		elapsed := time.Since(startTime)
		fmt.Printf("程式運行時間：%v\n", elapsed)
		fmt.Println("工作緒狀態：")
		fmt.Println("  preventSleep1: 執行中")
		return
	}

	if *killFlag != "" {
		if *killFlag == "preventSleep1" {
			cancel()
			fmt.Println("工作緒 preventSleep1 已被終止")
		} else {
			fmt.Printf("找不到對應的工作緒ID: %s\n", *killFlag)
		}
		return
	}

	select {}
}
