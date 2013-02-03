import flash.geom.Matrix;

class GUI.SkillHive.SkillHiveDrawHelper
{
    
    static var s_RingThickness:Number = 50;
    static var s_ShadeThickness:Number = 20;
    static var s_ShadowColor:Number = 0x000000;
    
    // Makes an arch using curveto. Note that the curveto only looks good from 0-45 degrees. So for greater angles we use several curves.
    // All in degrees. (Optimize could use rad.)
    // Clip - The movieclip to make the arch in.
    public static function MakeArch( clip:MovieClip, radius:Number, angle:Number, thickness:Number, startAngle:Number, color:Number, alpha:Number, strokeWidth:Number, strokeColor:Number,  drawShadow:Boolean, shadowBleedColor:Number)
    {
        var start:Number = Math.PI*(startAngle)/180;
        var end:Number   = Math.PI*(startAngle+angle)/180;

        var pieces:Number = Math.ceil(angle/45);
        var pieceSize:Number = Math.PI*(angle/pieces)/180;

        var far:Number = radius + thickness;
        var near:Number = radius;
        
        var lineAlpha:Number = strokeWidth > 0 ? 100 : 0;

        // IDEA: beginFill and lineStyle could be moved out of the function so that the user can choose color, alpha, storke, or gradient fill.
        clip.beginFill( color, alpha );
        clip.lineStyle( strokeWidth, strokeColor, lineAlpha);

        clip.moveTo( Math.sin(start) * far , -Math.cos(start) * far );
        // Split it into several pieces in case we go futher than 45 degrees.
        var halfPiece:Number = pieceSize/2;
        var pieceEnd:Number = start + pieceSize;
        for( var i=0; i!=pieces; i++ )
        {
            var farAnchor:Number = far / Math.cos( halfPiece );
            clip.curveTo( Math.sin(pieceEnd - halfPiece)*farAnchor ,-Math.cos(pieceEnd - halfPiece)*farAnchor, Math.sin(pieceEnd)*far ,-Math.cos(pieceEnd)*far );
            pieceEnd += pieceSize;
        }
        
        clip.lineTo( Math.sin(end) * near , -Math.cos(end) * near );
            
        // Split it into several pieces in case we go futher than 45 degrees.
        var pieceEnd:Number = end - pieceSize;
        for( var i=0; i!=pieces; i++ )
        {
            var nearAnchor:Number = near / Math.cos( halfPiece );
            clip.curveTo( Math.sin(pieceEnd + halfPiece)*nearAnchor ,-Math.cos(pieceEnd + halfPiece)*nearAnchor, Math.sin(pieceEnd)*near ,-Math.cos(pieceEnd)*near );
            pieceEnd -= pieceSize;
        }
        if (drawShadow)
        {
            var shadow:MovieClip = clip._parent.m_Shadow;
            DrawShade(shadow, pieceEnd, pieceSize, radius, thickness, end, pieces, shadowBleedColor);
        }
        clip.lineTo( Math.sin(start) * far , -Math.cos(start) * far );
        clip.endFill();
    }

    /**
     * Draws the outer and inner part of a shade
     * @param	shade
     * @param	pieceEnd
     * @param	pieceSize
     * @param	radius
     * @param	thickness
     * @param	end
     * @param	pieces
     */
    public static function DrawShade( clip:MovieClip, pieceEnd:Number, pieceSize:Number, radius:Number, thickness:Number, end:Number, pieces:Number, bleedColor:Number) : Void
    {
        if (clip == null)
        {
            return;
        }
        clip.clear();
        
        var matrix:Matrix = CreateGradientBoxMatrix(radius, s_RingThickness)
        var nearEdge:Number = radius - (thickness * 0.5)-5;
        var farEdge:Number = radius + (thickness * 0.5);
        var far:Number = farEdge + (s_ShadeThickness * 2) + 20;
        var near:Number = nearEdge - s_ShadeThickness;
        
        pieceEnd += pieceSize;
        
        var gradEnd:Number = 255;
        
        var maxSize:Number = radius + thickness + s_ShadeThickness;
        var constant:Number = gradEnd / maxSize;
       
        var shadeGrad:Number = Math.round( constant * s_ShadeThickness );
        var nearGrad:Number = Math.round( constant * (nearEdge + (s_ShadeThickness*0.5) ) );
        var farGrad:Number = Math.round( constant * (farEdge + s_ShadeThickness) );
     
        clip.beginGradientFill("radial", [bleedColor, bleedColor, s_ShadowColor, s_ShadowColor, bleedColor, bleedColor], [0,5, 30, 30, 1, 0], [1, nearGrad-shadeGrad, nearGrad, farGrad, farGrad+shadeGrad+5,gradEnd], matrix);
        clip.lineStyle(0, 0xFF0000, 0);
        
        clip.moveTo( Math.sin( pieceEnd ) * far , -Math.cos( pieceEnd ) * far );
        clip.lineTo( Math.sin( pieceEnd ) * near , -Math.cos( pieceEnd ) * near );

        
        for( var i=0; i!=pieces; i++ )
        {
            pieceEnd += pieceSize;   
            clip.lineTo(Math.sin(pieceEnd) * near , -Math.cos(pieceEnd) * near );
        }
        
        
        clip.lineTo( Math.sin(end) * far , -Math.cos(end) * far );
        far += 20;
        for( var i=0; i!=pieces; i++ )
        {
            pieceEnd -= pieceSize;
            clip.lineTo(Math.sin(pieceEnd) * far , -Math.cos(pieceEnd) * far );
        }
        
    }


    /** DRAWING FUNCTIONALITY **/
    private static function CreateGradientBoxMatrix(radius:Number, thickness:Number) : Matrix
    {
        var matrix:Matrix = new Matrix();
        var boxsize:Number = (radius + thickness) * 2;
        var offset:Number = -(radius + thickness);
        matrix.createGradientBox(boxsize, boxsize, 0, offset, offset); 
        return matrix;
    }
}