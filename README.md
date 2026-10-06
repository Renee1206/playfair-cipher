# Playfair Cipher in x86 Assembly

使用 **x86 Assembly（MASM）** 實作經典的 **Playfair Cipher 加密演算法**。  
程式透過 **Irvine32 Library** 進行主控台輸入與輸出，並完成明文前處理、字母配對以及 Playfair 5×5 矩陣加密。

## 專案介紹

Playfair Cipher 是一種以兩個字母為一組（Digraph）進行加密的古典密碼技術。

本專案使用 Assembly Language 實作 Playfair Cipher 的加密流程。使用者輸入一段英文明文後，程式會先進行格式化處理，再依照固定的 5×5 Playfair Matrix 將每組字母轉換為密文。

## 功能特色

- 使用 **MASM x86 Assembly** 實作
- 使用 **Irvine32 Library** 處理 Console I/O
- 自動移除非英文字母
- 自動將小寫字母轉為大寫
- 將 `J` 轉換為 `I`
- 相同字母出現在同一組時插入 `X`
- 明文長度為奇數時自動補上 `X`
- 將處理後的明文以兩個字母為一組顯示
- 依照 Playfair Cipher 規則產生密文

## Playfair Matrix

程式使用以下固定的 5×5 字母矩陣：

```text
M O N A R
C H Y B D
E F G I K
L P Q S T
U V W X Z
```

此矩陣是以關鍵字 `MONARCHY` 建立後固定寫入程式中。

由於 Playfair Cipher 使用 5×5 矩陣，因此程式將 `I` 與 `J` 視為同一個字母，輸入中的 `J` 會先轉換為 `I`。

## 明文前處理

在進行加密之前，程式會先處理使用者輸入的文字。

處理規則包含：

1. 移除非英文字母字元
2. 將所有英文字母轉換為大寫
3. 將 `J` 轉換為 `I`
4. 每兩個字母分成一組
5. 若同一組出現相同字母，插入 `X`
6. 若最後剩下一個字母，補上 `X`

例如輸入：

```text
instruments
```

處理後：

```text
IN ST RU ME NT SX
```

## 加密規則

對每一組兩個字母，程式會先找出它們在 Playfair Matrix 中的位置，再依照以下規則進行加密。

### 1. Same Row

如果兩個字母位於**同一橫列**，兩個字母都取其右方的字母。

若已位於最右側，則循環回到該橫列最左側。

### 2. Same Column

如果兩個字母位於**同一直行**，兩個字母都取其下方的字母。

若已位於最下方，則循環回到該直行最上方。

### 3. Rectangle Rule

如果兩個字母位於不同橫列且不同直行，則以兩個字母的位置形成矩形，分別取同一橫列另一個角落的字母。

## 執行範例

輸入：

```text
Please input the plaintext: instruments
```

程式會先顯示處理後的明文：

```text
Modified plaintext: IN ST RU ME NT SX
```

接著輸出密文：

```text
The ciphertext is: GA TL MZ CL RQ XA
```

因此：

```text
Plaintext:
INSTRUMENTSX

Ciphertext:
GATLMZCLRQXA
```

## 專案結構

```text
playfair-cipher/
│
├── 1122913_hw6.sln
├── 1122913_hw6/
│   ├── 1122913_hw6.asm
│   ├── 1122913_hw6.vcxproj
│   └── 1122913_hw6.vcxproj.filters
│
└── .gitignore
```

主要程式位於：

```text
1122913_hw6/1122913_hw6.asm
```

程式主要包含：

- 明文輸入與前處理
- Playfair Cipher 加密流程
- 5×5 Matrix 字母位置搜尋
- Same Row / Same Column / Rectangle Rule
- 密文輸出

## 開發環境

- Windows
- Microsoft Visual Studio
- MASM（Microsoft Macro Assembler）
- x86 / Win32
- Irvine32 Library

目前專案設定以 **Debug | Win32** 為主，並使用：

```text
C:\Irvine
```

作為 Irvine32 Library 的 Include 與 Library 路徑。

如果 Irvine32 安裝在其他位置，需要自行修改 Visual Studio 專案中的相關路徑設定。

## 執行方式

Clone repository：

```bash
git clone https://github.com/Renee1206/playfair-cipher.git
```

使用 Visual Studio 開啟：

```text
1122913_hw6.sln
```

接著：

1. 確認已安裝並設定 Irvine32 Library
2. 將組態設定為 `Debug`
3. 將平台設定為 `Win32`
4. Build Solution
5. 執行程式
6. 輸入欲加密的英文文字

## 程式流程

```text
User Input
    ↓
Remove Non-Alphabet Characters
    ↓
Convert to Uppercase
    ↓
Replace J with I
    ↓
Split into Letter Pairs
    ↓
Insert / Append X when necessary
    ↓
Locate Characters in 5×5 Matrix
    ↓
Apply Playfair Encryption Rules
    ↓
Generate Ciphertext
```

## 已知限制

本程式統一使用 `X` 作為重複字母與奇數長度明文的填充字母。

因此，當原始文字本身包含連續的 `X`，或最後一個字母為 `X` 時，可能產生 `XX` 配對。例如：

```text
XX
```

由於填充字母本身也是 `X`，因此無法像一般字母一樣有效分隔重複字元。

若要進一步完善 Playfair Cipher 的前處理流程，可在重複字母本身為 `X` 時改用其他填充字母，例如 `Q`。
