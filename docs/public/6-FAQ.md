### 1. 如何修改倍速选项

为了修改倍速选项，需要修改以下两个文件，它们分别负责横屏和竖屏模式下的倍速选择UI：

- PLVMediaPlayerMoreLayoutPort.ets (竖屏模式下“更多”面板中的倍速选项)
- PLVMediaPlayerSpeedSelectLayoutLand.ets (横屏模式下独立的倍速选择面板)

这两个文件都独立定义了`supportSpeeds`数组，因此需要分别进行修改，以确保在不同布局下都能看到并选择倍速。以下示例如何添加2.5倍速：

#### 步骤说明：

1. **修改 `PLVMediaPlayerMoreLayoutPort.ets` 文件。**

**修改前：**
```typescript
private supportSpeeds: string[] = ["0.5", "0.75", "1", "1.25", "1.5", "2", "3"]
```

**修改后：**
在`"2"`和`"3"`之间插入`"2.5"`。为了保持选项的逻辑顺序，建议将其放在`"2"`之后。

```typescript
private supportSpeeds: string[] = ["0.5", "0.75", "1", "1.25", "1.5", "2", "2.5", "3"] // 添加了 "2.5"
```

2. **修改 `PLVMediaPlayerSpeedSelectLayoutLand.ets` 文件。**

**修改前：**
```typescript
private supportSpeeds: string[] = ["0.5", "0.75", "1", "1.25", "1.5", "2", "3"]
```

**修改后：**
同样，在`"2"`和`"3"`之间插入`"2.5"`。

```typescript
private supportSpeeds: string[] = ["0.5", "0.75", "1", "1.25", "1.5", "2", "2.5", "3"] // 添加了 "2.5"
```

完成这两个文件的修改后，重新编译并运行您的应用，您将在播放器的倍速选择界面中看到2.5倍速选项。
