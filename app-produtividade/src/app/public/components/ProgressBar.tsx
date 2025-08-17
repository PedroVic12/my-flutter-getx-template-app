"use client";

import React from 'react';
import { Box, Typography, LinearProgress } from '@mui/material';

interface ProgressBarProps {
  totalCount: number;
  maxCount: number;
}

export const ProgressBar: React.FC<ProgressBarProps> = ({ totalCount, maxCount }) => {
  const progress = (totalCount / maxCount) * 100;

  return (
    <Box sx={{ my: 4 }}>
      <Typography variant="h5" color="error" gutterBottom>
        Desempenho da semana: {totalCount}/{maxCount}
      </Typography>
      <LinearProgress 
        variant="determinate" 
        value={progress} 
        sx={{ 
          height: 25, 
          borderRadius: 5,
          backgroundColor: '#e0e0e0',
          '& .MuiLinearProgress-bar': {
            backgroundColor: '#1976d2',
          }
        }} 
      />
    </Box>
  );
};