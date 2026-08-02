package com.souqira.android.ui.theme

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Shapes
import androidx.compose.material3.Typography
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

private val SouqiraPrimary = Color(0xFF0A4F66)
private val SouqiraSecondary = Color(0xFF2B7EA1)
private val SouqiraAccent = Color(0xFF0F6A86)
private val SouqiraCanvas = Color(0xFFF2F6F9)
private val SouqiraCard = Color(0xFFFFFFFF)
private val SouqiraTextMain = Color(0xFF1C3347)
private val SouqiraTextMuted = Color(0xFF6B8399)

private val LightColors = lightColorScheme(
    primary = SouqiraPrimary,
    onPrimary = Color.White,
    secondary = SouqiraSecondary,
    onSecondary = Color.White,
    tertiary = SouqiraAccent,
    background = SouqiraCanvas,
    onBackground = SouqiraTextMain,
    surface = SouqiraCard,
    onSurface = SouqiraTextMain,
    surfaceVariant = Color(0xFFEEF3F7),
    onSurfaceVariant = SouqiraTextMuted,
    outline = Color(0xFFDCE6EE)
)
private val DarkColors = darkColorScheme()

private val SouqiraTypography = Typography(
    headlineMedium = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Bold,
        fontSize = 28.sp,
        lineHeight = 34.sp
    ),
    titleLarge = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.SemiBold,
        fontSize = 22.sp,
        lineHeight = 28.sp
    ),
    bodyLarge = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Medium,
        fontSize = 16.sp,
        lineHeight = 22.sp
    ),
    bodyMedium = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Normal,
        fontSize = 14.sp,
        lineHeight = 20.sp
    ),
    labelLarge = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.SemiBold,
        fontSize = 14.sp,
        lineHeight = 18.sp
    )
)

private val SouqiraShapes = Shapes(
    small = RoundedCornerShape(10.dp),
    medium = RoundedCornerShape(16.dp),
    large = RoundedCornerShape(24.dp)
)

@Composable
fun SouqiraTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = LightColors,
        typography = SouqiraTypography,
        shapes = SouqiraShapes,
        content = content
    )
}
