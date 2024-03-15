# qrcodescanner

qr code scanner plugin

## Install

```bash
npm install qrcodescanner
npx cap sync
```

## API

<docgen-index>

* [`echo(...)`](#echo)
* [`scan(...)`](#scan)
* [`pluginPermissionMethod()`](#pluginpermissionmethod)
* [`opencamera()`](#opencamera)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### echo(...)

```typescript
echo(options: { value: string; }) => Promise<{ value: string; }>
```

| Param         | Type                            |
| ------------- | ------------------------------- |
| **`options`** | <code>{ value: string; }</code> |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


### scan(...)

```typescript
scan(options: {}) => Promise<any>
```

| Param         | Type            |
| ------------- | --------------- |
| **`options`** | <code>{}</code> |

**Returns:** <code>Promise&lt;any&gt;</code>

--------------------


### pluginPermissionMethod()

```typescript
pluginPermissionMethod() => Promise<any>
```

**Returns:** <code>Promise&lt;any&gt;</code>

--------------------


### opencamera()

```typescript
opencamera() => Promise<any>
```

**Returns:** <code>Promise&lt;any&gt;</code>

--------------------

</docgen-api>
